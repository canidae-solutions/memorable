use Amnesia

defdatabase Database do
  deftable Collection, [:id, :name], type: :set do
    @type t :: %Collection{id: id, name: String.t}
    @type id :: integer
  end
  deftable Image, [:id, :collection_id, :path], type: :set do
    @type t :: %Image{id: id, collection_id: Collection.id, path: String.t}
    @type id :: integer
  end
end

defmodule MyRouter do
  use Plug.Router

  plug :match
  plug :dispatch

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
  alias Database.Collection

  def start(_type, _args) do
    Supervisor.start_link(
      [
        {Plug.Cowboy, plug: MyRouter, scheme: :http, options: [port: 4000]},
        {Task, &amnesia_test/0},
      ],
      strategy: :one_for_one
    )
    |> tap(fn _ -> Logger.info("memorable listening on port 4000") end)
  end

  def amnesia_test() do
    Amnesia.transaction do
      c20250201 = %Collection{id: 1, name: "Methven Park + Merri Creek Walk"} |> Collection.write
      IO.inspect(Collection.read(1))
    end
  end
end
