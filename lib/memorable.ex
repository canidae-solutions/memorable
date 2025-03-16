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

  def start(_type, _args) do
    Supervisor.start_link(
      [
        {Plug.Cowboy, plug: MyRouter, scheme: :http, options: [port: 4000]},
      ],
      strategy: :one_for_one
    )
    |> tap(fn _ -> Logger.info("memorable listening on port 4000") end)
  end
end
