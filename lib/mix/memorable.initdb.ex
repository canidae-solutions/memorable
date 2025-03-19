defmodule Mix.Tasks.Memorable.InitDb do
  @shortdoc "Initializes the Memorable database"

  use Mix.Task
  require Logger

  @impl Mix.Task
  def run(_) do
    nodes = [node()]
    Memento.stop()

    with :ok <- Memento.Schema.create(nodes),
         _ <- Memento.start(),
         :ok <- Memento.Table.create(Memorable.Collection, disc_copies: nodes) do
      Logger.info("Memorable database initialized")
    else
      {:error, err} -> Logger.error("Error initializing Memorable database: #{inspect(err)}")
    end
  end
end
