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
        {Task, &memento_test/0}
      ],
      strategy: :one_for_one
    )
    |> tap(fn _ -> Logger.info("memorable listening on port 4000") end)
  end

  def memento_test() do
    Memento.transaction!(fn ->
      _c20250201 =
        %Data.Collection{id: 1, name: "Methven Park + Merri Creek Walk"}
        |> Memento.Query.write()

      IO.inspect(Memento.Query.all(Data.Collection))
    end)
  end
end
