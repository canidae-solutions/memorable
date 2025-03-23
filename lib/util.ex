defmodule Memorable.Util do
  @moduledoc """
  Various utility functions used across memorable.
  """
  @moduledoc since: "1.0.0"

  @typedoc """
  A memorable ID.

  See `generate_id/0` for format details.
  """
  @type id() :: String.t()

  @doc """
  Generates an ID for use as identifiers for various memorable objects.

  Each ID is a base32-encoded [UUIDv7](https://hexdocs.pm/uniq/Uniq.UUID.html#uuid7/1), with padding removed and
  converted to lowercase.
  """
  @doc since: "1.0.0"
  @spec generate_id() :: id()
  def generate_id() do
    Uniq.UUID.uuid7(:raw)
    |> Base.encode32(padding: false, case: :lower)
  end

  @doc """
  Given a path relative to the image store, [...]

  Returns an error if the path tries to break out of the image store.
  """
  @spec images_path(Path.t() | nil) :: {:ok, Path.t()} | :error
  def images_path(path \\ nil) do
    # TODO: handle nil here, for getting the root with `images_path()`
    with {:ok, path} <- Path.safe_relative(path) do
      {:ok, Path.join(Application.fetch_env!(:memorable, :images_path), path)}
    end
  end
end
