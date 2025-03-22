defmodule Memorable.Router do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  get "/" do
    send_resp(conn, 200, "Hello world")
  end

  match _ do
    send_resp(conn, 404, "oops")
  end
end

defmodule Memorable do
  @moduledoc """
  Documentation for `Memorable`.
  """
  use Application
  require Logger
  alias Memorable.Data

  def start(_type, _args) do
    Supervisor.start_link(
      [
        {Plug.Cowboy, plug: Memorable.Router, scheme: :http, options: [port: 4000]},
        {Task, &test/0}
      ],
      strategy: :one_for_one
    )
    |> tap(fn _ -> Logger.info("memorable listening on port 4000") end)
  end

  def test() do
    alias Data.Image

    Data.Collection.new("Test Collection")
    |> Data.Collection.rename("Renamed Collection")
    |> Data.Collection.write()
    |> IO.inspect()

    image = %Image{
      id: 1,
      collection_id: nil,
      path: "test/data/20250317_0_0028_01.jpg",
      imported_datetime: DateTime.utc_now()
    }

    # `Command` in rust needs to call waitpid(2), which fails with ECHILD when the signal handler
    # for SIGCHLD is set to SIG_IGN, as is done in the erlang vm.
    # <https://github.com/rusterlium/rustler/issues/446>
    # <http://erlang.org/pipermail/erlang-questions/2020-November/100109.html>
    :os.set_signal(:sigchld, :default)

    Image.read_metadata(image) |> IO.inspect()
    Data.Image.DerivedMetadata.from_image(image) |> IO.inspect()
  end
end

# runs processes using rust ffi.
#
# erlang’s port api is busted for any program that needs eof on stdin before writing its output,
# because closing a port closes both stdin and stdout [1]. libraries like porcelain [2] get around
# this by running programs with a wrapper that can close stdin on our behalf, but sadly porcelain
# has a serious flaw that is unlikely to be fixed for the foreseeable future [3].
# 1. <http://erlang.org/pipermail/erlang-questions/2013-July/074905.html>
# 2. <https://hex.pm/packages/porcelain>
# 3. <https://github.com/alco/porcelain/issues/50#issuecomment-401462266>
defmodule Subprocess do
  use Rustler, otp_app: :memorable, crate: "subprocess"

  # When your NIF is loaded, it will override this function.
  def exiftool_json(_image_data), do: :erlang.nif_error(:nif_not_loaded)
end
