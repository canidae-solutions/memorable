defmodule Memorable.Data.Collection do
  @moduledoc """
  Functions for working with memorable collections.

  Collections can be thought of as analogous to a photo album, or a gallery. They are the primary mechanism for
  organizing images.

  Collections are comprised of the following fields:
  - `id`: A base32-encoded UUIDv7 representing the collection
  - `name`: The human-readable name of the collection
  - `creation_date`: A `DateTime` representing the time at which the collection was created.
  """
  @moduledoc since: "1.0.0"

  @derive {Inspect, only: [:id, :name, :creation_date]}
  use Memento.Table, attributes: [:id, :name, :creation_date]

  @type t :: %__MODULE__{id: Memorable.Util.id(), name: String.t(), creation_date: DateTime.t()}

  @doc """
  Creates a new collection.

  Accepts the name to give the collection, and creates a new collection with a randomly-generated ID, and the current
  time as the `creation_date`.
  """
  @doc since: "1.0.0"
  @spec new(String.t()) :: t()
  def new(name) do
    %__MODULE__{
      id: Memorable.Util.generate_id(),
      name: name,
      creation_date: DateTime.utc_now()
    }
  end

  @doc """
  Renames a collection by changing the `name` field to `new_name`.
  """
  @doc since: "1.0.0"
  @spec rename(t(), String.t()) :: t()
  def rename(collection, new_name) do
    Map.put(collection, :name, new_name)
  end

  @doc """
  Fetches a collection from the memorable database by ID.

  Returns:
  - `{:ok, collection}`: When the query was successful.
  - `{:ok, nil}`: When no collection exists with the given ID.
  - `{:error, error_value}`: When there was an error querying the database.
  """
  @doc since: "1.0.0"
  @spec query_id(String.t()) :: {:ok, t() | nil} | {:error, any()}
  def query_id(id) do
    Memento.transaction(fn ->
      Memento.Query.read(__MODULE__, id)
    end)
  end

  @doc """
  Writes a collection to the memorable database.

  If a collection already exists with the same ID in the database, the collection is updated. Otherwise, a new
  collection is created.

  Returns `{:ok, collection}` if the write was successful, and `{:error, error_value}` if the write failed.
  """
  @doc since: "1.0.0"
  @spec write(t()) :: {:ok, t()} | {:error, any()}
  def write(collection) do
    Memento.transaction(fn ->
      Memento.Query.write(collection)
    end)
  end
end
