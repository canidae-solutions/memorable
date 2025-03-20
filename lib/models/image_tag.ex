defmodule Memorable.Data.ImageTag do
  use Memento.Table,
    attributes: [:image, :tag],
    type: :bag
end
