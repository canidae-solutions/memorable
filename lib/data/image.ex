defmodule Memorable.Data.Image do
  use Memento.Table, attributes: [:id, :collection_id, :path, :timestamp, :upload_date]
end
