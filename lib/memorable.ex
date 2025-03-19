defmodule Memorable.Collection do
  use Memento.Table, attributes: [:id, :name]
end

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

  def start(_type, _args) do
    # TODO: only needs to be run once per db - move to init task
    # nodes = [node()]
    # Memento.stop()
    # Memento.Schema.create(nodes)
    # Memento.start()

    # Memento.Table.create!(Memorable.Collection, disc_copies: nodes)

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
        %Memorable.Collection{id: 1, name: "Methven Park + Merri Creek Walk"}
        |> Memento.Query.write()

      IO.inspect(Memento.Query.all(Memorable.Collection))
    end)
  end
end
