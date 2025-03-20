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
end
