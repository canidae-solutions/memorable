defmodule MemorableTest do
  use ExUnit.Case
  doctest Memorable

  test "greets the world" do
    assert Memorable.hello() == :world
  end
end
