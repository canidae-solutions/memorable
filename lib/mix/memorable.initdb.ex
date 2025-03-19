defmodule Mix.Tasks.Memorable.InitDb do
  @shortdoc "Initializes the Memorable database"

  @tables [
    Memorable.Collection
  ]

  use Mix.Task
  require Logger

  @impl Mix.Task
  def run(_) do
    with :ok <- create_schema(),
         :ok <- create_tables(@tables) do
      Logger.info("Memorable database initialized")
    else
      {:error, _} -> Logger.error("Memorable database initialization failed")
    end
  end

  defp create_schema() do
    Memento.stop()

    case Memento.Schema.create([node()]) do
      :ok ->
        Logger.info("Created schema for node #{node()}")
        Memento.start()
        :ok

      {:error, {_, {:already_exists, _}}} ->
        Logger.debug("Schema for node #{node()} already exists, skipping")
        Memento.start()
        :ok

      {:error, err} ->
        Logger.error("Error creating schema: #{inspect(err)}")
        {:error, err}
    end
  end

  defp create_tables([]), do: :ok

  defp create_tables([table | rest]) do
    case Memento.Table.create(table, disc_copies: [node()]) do
      :ok ->
        Logger.info("Created table #{inspect(table)}")
        create_tables(rest)

      {:error, {:already_exists, _}} ->
        Logger.debug("Table #{inspect(table)} already exists, skipping")
        create_tables(rest)

      {:error, err} ->
        Logger.error("Error creating table #{inspect(table)}: #{inspect(err)}")
        {:error, err}
    end
  end
end
