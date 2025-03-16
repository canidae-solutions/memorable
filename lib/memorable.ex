defmodule Memorable.HelloWorldPlug do
  import Plug.Conn

  def init(options) do
    # initialize options
    options
  end

  def call(conn, _opts) do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, "Hello world")
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
        {Plug.Cowboy, plug: Memorable.HelloWorldPlug, scheme: :http, options: [port: 4000]},
      ],
      strategy: :one_for_one
    )
    |> tap(fn _ -> Logger.info("memorable listening on port 4000") end)
  end
end
