defmodule Memorable.Data.CollectionTest do
  use ExUnit.Case
  alias Memorable.Data.Collection
  doctest Memorable.Data.Collection

  setup_all do
    on_exit(fn ->
      Memento.Table.clear(Collection)
    end)

    [collection: Collection.new("Diffies")]
  end

  describe "Collection.new/1" do
    test "creates a collection with the given name", %{collection: collection} do
      assert String.length(collection.id) == 26
      assert collection.name == "Diffies"
      assert %DateTime{} = collection.creation_date
    end
  end

  describe "Collection.rename/2" do
    test "renames a collection to the supplied name", %{collection: collection} do
      collection = Collection.rename(collection, "Scungy Diffies")

      assert collection.name == "Scungy Diffies"
    end
  end

  describe "Collection.write/1" do
    test "writes a collection to the database", %{collection: collection} do
      {:ok, collection} = Collection.write(collection)

      {:ok, all_collections} = Memento.transaction(fn -> Memento.Query.all(Collection) end)
      assert Enum.any?(all_collections, &(&1.id == collection.id))
    end
  end

  describe "Collection.query_id/1" do
    test "queries a collection from the database by ID", %{collection: collection} do
      {:ok, collection_a} = Collection.write(collection)
      {:ok, collection_b} = Collection.query_id(collection_a.id)

      assert collection_a.id == collection_b.id
    end

    test "returns nil when querying an ID that doesn't exist" do
      assert {:ok, nil} = Collection.query_id("fake id")
    end
  end
end
