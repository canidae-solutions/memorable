defmodule Memorable.UtilTest do
  use ExUnit.Case
  alias Memorable.Util
  doctest Memorable.Util

  describe "generate_id/0" do
    test "generates a correctly formatted ID" do
      id = Util.generate_id()

      assert String.length(id) == 26
      assert String.downcase(id) == id
      refute String.ends_with?(id, "=")

      assert String.match?(id, ~r/^[a-z2-7]{26}$/)
    end
  end
end
