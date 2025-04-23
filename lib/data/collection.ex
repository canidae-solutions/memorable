defmodule Memorable.Data.Collection do
  @moduledoc """
  Functions for working with memorable collections.

  Collections can be thought of as analogous to a photo album, or a gallery. They are the primary mechanism for
  organizing images.

  ## Fields
  - `id`: An [ID](`t:Memorable.Util.id/0`) representing the collection
  - `name`: The human-readable name of the collection
  - `created_datetime`: A `DateTime` representing the time at which the collection was created.
  """
  @moduledoc since: "1.0.0"

  alias Memorable.Data.Image

  @derive {Inspect, only: [:id, :name, :created_datetime]}
  use Memento.Table, attributes: [:id, :name, :created_datetime]

  @type id :: Memorable.Util.id()
  @type t :: %__MODULE__{
          id: __MODULE__.id(),
          name: String.t(),
          created_datetime: DateTime.t()
        }

  @doc """
  Creates a new collection.

  Accepts the name to give the collection, and creates a new collection with a randomly-generated ID, and the current
  time as the `created_datetime`.
  """
  @doc since: "1.0.0"
  @spec new(String.t()) :: t()
  def new(name) do
    %__MODULE__{
      id: Memorable.Util.generate_id(),
      name: name,
      created_datetime: DateTime.utc_now()
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
  Fetches all collections from the memorable database.

  Returns:
  - `{:ok, collections}`: When the query was successful. The list may be empty, if there are no collections.
  - `{:error, error_value}`: When there was an error querying the database.
  """
  @doc since: "1.0.0"
  @spec all() :: {:ok, [t()]} | {:error, any()}
  def all() do
    Memento.transaction(fn ->
      Memento.Query.all(__MODULE__)
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

  @doc """
  Does not write the image to the database.
  """
  @spec import(t(), Path.t()) :: {:ok, t()} | {:error, any()}
  def import(%__MODULE__{id: collection_id} = collection, original_path) do
    %Image{path: filename} = image = Image.new(collection, original_path, DateTime.utc_now())

    with {:image_path, {:ok, image_path}} <-
           {:image_path, Image.path(image, collection)},
         {:collection_path, {:ok, collection_path}} <-
           {:collection_path, path(collection)},
         {:mkdir, :ok} <- {:mkdir, File.mkdir_p(collection_path)} do
      with {:error, error} <- File.ln(original_path, image_path),
           {:error, error} <- File.cp(original_path, image_path) do
        {:error, {:link_or_copy, error}}
      else
        :ok -> {:ok, image}
      end
    else
      {:image_path, :error} -> {:error, :image_path}
      {:collection_path, :error} -> {:error, :collection_path}
      {:mkdir, {:error, error}} -> {:error, {:mkdir, error}}
    end
  end

  @spec path(t()) :: {:ok, Path.t()} | :error
  def path(%__MODULE__{id: id}) do
    Memorable.Util.images_path(id)
  end
end
