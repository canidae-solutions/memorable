defmodule Memorable.Data.Image do
  @derive {Inspect, except: []}
  use Memento.Table, attributes: [:id, :collection_id, :path, :imported_datetime]

  @type t :: %__MODULE__{
          id: Memorable.Util.id(),
          collection_id: Memorable.Data.Collection.id(),
          path: Path.t(),
          imported_datetime: DateTime.t()
        }
  @type metadata :: %{String.t() => any()}

  @spec read_metadata(t()) :: {:ok, metadata()} | {:error, any()}
  def read_metadata(%__MODULE__{path: path}) do
    with {:file_read, {:ok, data}} <- {:file_read, File.read(path)},
         %{status: 0, stdout: stdout} <- Subprocess.exiftool_json(data),
         {:json_decode, {:ok, result}} <- {:json_decode, JSON.decode(to_string(stdout))} do
      {:ok, List.first(result)}
    else
      {:file_read, {:error, reason}} -> {:error, {:file_read, reason}}
      %{status: nil} -> {:error, :exiftool_exit_signal}
      %{status: other} -> {:error, {:exiftool_exit_status, other}}
      {:json_decode, {:error, reason}} -> {:error, {:json_decode, reason}}
    end
  end
end

defmodule Memorable.Data.Image.DerivedMetadata do
  alias Memorable.Data.Image

  # `image_id` is 1:1 with an Image `id`
  use Memento.Table,
    attributes: [
      :image_id,
      :file_hash,
      :original_datetime,
      :lens_model,
      :body_model,
      :focal_length,
      :aperture,
      :exposure_time,
      :iso
    ]

  @type t :: %__MODULE__{
          image_id: Image.id(),
          file_hash: binary(),
          original_datetime: NaiveDateTime.t(),
          lens_model: String.t(),
          body_model: String.t(),
          focal_length: float(),
          aperture: float(),
          exposure_time: String.t(),
          iso: integer()
        }

  @spec from_image(Image.t()) :: {:ok, t()} | {:error, any()}
  def from_image(%Image{id: image_id, path: path} = image) do
    with {:read_file, {:ok, data}} <- {:read_file, File.read(path)},
         {:read_metadata, {:ok, metadata}} <-
           {:read_metadata, Image.read_metadata(image)} do
      %__MODULE__{
        image_id: image_id,
        file_hash: :crypto.hash(:sha256, data),
        original_datetime: original_datetime(metadata),
        lens_model: Map.get(metadata, "LensID"),
        body_model: Map.get(metadata, "Model"),
        focal_length: focal_length(metadata),
        aperture: Map.get(metadata, "Aperture"),
        exposure_time: Map.get(metadata, "ExposureTime"),
        iso: Map.get(metadata, "ISO")
      }
    else
      {:read_file, error} -> {:error, {:read_file, error}}
      {:read_metadata, error} -> {:error, {:read_metadata, error}}
    end
  end

  @spec original_datetime(Image.metadata()) :: NaiveDateTime.t() | nil
  defp original_datetime(metadata) do
    with result when result != nil <- Map.get(metadata, "DateTimeOriginal") do
      NaiveDateTime.from_iso8601!(result)
    end
  end

  @spec focal_length(Image.metadata()) :: float() | nil
  defp focal_length(metadata) do
    with result when result != nil <- Map.get(metadata, "FocalLength") do
      case Float.parse(result) do
        {result, " mm"} -> result
        {_, _} -> raise "FocalLength is not in mm: #{result}"
        :error -> raise "FocalLength does not parse as float: #{result}"
      end
    end
  end
end
