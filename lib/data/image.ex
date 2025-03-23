defmodule Memorable.Data.Image do
  @moduledoc """
  Functions for working with images in memorable.

  An `Image` represents one image stored in a memorable `Collection`. Images are always associated with exactly one
  collection - it is not possible for one image to be a part of two different collections.

  ## Structure
  The `Image` struct holds information about an image relevant to storage and relations. It does not contain other
  metadata about the image itself, such as when the photo was taken or other data stored in the image's EXIF tags. These
  are instead kept in the `Memorable.Data.Image.DerivedMetadata` table.

  ## Fields
  - `id`: An [ID](`t:Memorable.Util.id/0`) representing the image.
  - `collection_id`: The [ID](`t:Memorable.Util.id/0`) of the `Memorable.Data.Collection` the image is a part of.
  - `path`: The path to the image file on disk, relative to the associated collection's folder.
  - `imported_datetime`: A `DateTime` representing the time at which the image was imported into the memorable database.
  """
  @moduledoc since: "1.0.0"
  @derive {Inspect, except: []}
  use Memento.Table, attributes: [:id, :collection_id, :path, :imported_datetime]

  @type t :: %__MODULE__{
          id: Memorable.Util.id(),
          collection_id: Memorable.Data.Collection.id(),
          # TODO: rename this field to `filename`
          path: Path.t(),
          imported_datetime: DateTime.t()
        }
  @type metadata :: %{String.t() => any()}

  @doc """
  Reads metadata from the image.

  To get metadata from the image, memorable calls out to `exiftool` installed on the system to obtain all EXIF tags
  stored on the image. See `Subprocess`, or the code in `native/subprocess` for details on how this is done.

  Returns:
  - `{:ok, metadata}`: A map from EXIF tags to their values, for all tags in the image, when the read was successful.
  - `{:error, :image_path}`: When the path to the associate image could not be calculated.
  - `{:error, {:read_file, error}}`: When an error occured reading the image file from disk.
  - `{:error, :exiftool_exit_signal}`: When `exiftool` exits due to receiving a signal.
  - `{:error, {:exiftool_exit_status, status_code}}`: When `exiftool` exits with a non-zero status code.
  - `{:error, {:json_decode, error}}`: When parsing the `exiftool` JSON response fails.
  """
  @doc since: "1.0.0"
  @spec read_metadata(t(), Collection.t()) :: {:ok, metadata()} | {:error, any()}
  def read_metadata(image, collection) do
    with {:image_path, {:ok, path}} <- {:image_path, path(image, collection)},
         {:file_read, {:ok, data}} <- {:file_read, File.read(path)},
         %{status: 0, stdout: stdout} <- Subprocess.exiftool_json(data),
         {:json_decode, {:ok, result}} <- {:json_decode, JSON.decode(to_string(stdout))} do
      {:ok, List.first(result)}
    else
      {:image_path, :error} -> {:error, :image_path}
      {:file_read, {:error, reason}} -> {:error, {:file_read, reason}}
      %{status: nil} -> {:error, :exiftool_exit_signal}
      %{status: other} -> {:error, {:exiftool_exit_status, other}}
      {:json_decode, {:error, reason}} -> {:error, {:json_decode, reason}}
    end
  end

  @spec new(Collection.t(), Path.t(), DateTime.t()) :: t()
  def new(%Collection{id: collection_id}, original_path, imported_datetime) do
    id = Memorable.Util.generate_id()
    extension = Path.extname(original_path)
    filename = "#{id}#{extension}"

    %__MODULE__{
      id: id,
      collection_id: collection_id,
      path: filename,
      imported_datetime: imported_datetime
    }
  end

  @spec path(t(), Collection.t()) :: {:ok, Path.t()} | :error
  def path(%__MODULE__{path: filename}, %Collection{id: collection_id}) do
    Memorable.Util.images_path(Path.join(collection_id, filename))
  end
end

defmodule Memorable.Data.Image.DerivedMetadata do
  @moduledoc """
  Metadata associated with images.

  Where `Memorable.Data.Image` holds information about the image's internal representation within memorable,
  `DerivedMetadata` contains information about the image itself. When an image is imported into memorable,
  `from_image/1` is called to extract metadata from EXIF tags, which gets stored in the memorable database for quick
  access.

  ## Fields
  - `image_id`: The [ID](`t:Memorable.Util.id/0`) of the `Memorable.Data.Image` this metadata is associated with.
  - `file_hash`: A tuple containing the hash type, and the hash of the image file this metadata was derived from. This
    is used to ensure that the metadata stored in the table is up to date, and matches the image on disk.

  The following fields are retrieved from EXIF metadata stored in the image, and may be `nil` if the associated tags are
  not present on the image:
  - `original_datetime`: A `NaiveDateTime` representing when the image was taken.
  - `lens_model`: The lens used to take the photo.
  - `body_model`: The camera body used to take the photo.
  - `focal_length`: The focal length the image was taken at, in millimetres.
  - `aperture`: The aperture the image was taken at, represented as an f-number.
  - `exposure_time`: The duration of time the image was exposed for, in seconds expressed as a rational (eg. "1/1250").
  - `iso`: The ISO sensitivity the image was taken at.
  """
  @moduledoc since: "1.0.0"
  alias Memorable.Data.Image.DerivedMetadata
  alias Memorable.Data.Image.DerivedMetadata
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

  @doc """
  Reads and parses metadata for a `Memorable.Data.Image`.

  EXIF tags from an image file are retrieved with `Memorable.Data.Image.read_metadata/1`, and then parsed into the
  format described above.

  Returns:
  - `{:ok, metadata}`: When metadata was successfully read and parsed from the image.
  - `{:error, {:read_file, error}}`: When an error occured reading the image file from disk.
  - `{:error, {:read_metadata, error}}`: When an error occurred while extracting EXIF tags from the image file.
  """
  @doc since: "1.0.0"
  @spec from_image(Image.t(), Collection.t()) :: {:ok, t()} | {:error, any()}
  def from_image(%Image{id: image_id} = image, collection) do
    with {:image_path, {:ok, path}} <- Image.path(image, collection),
         {:read_file, {:ok, data}} <- {:read_file, File.read(path)},
         {:read_metadata, {:ok, metadata}} <-
           {:read_metadata, Image.read_metadata(image)} do
      sha256 = Base.encode16(:crypto.hash(:sha256, data), case: :lower)

      {:ok,
       %__MODULE__{
         image_id: image_id,
         file_hash: {:sha256, sha256},
         original_datetime: original_datetime(metadata),
         lens_model: Map.get(metadata, "LensID"),
         body_model: Map.get(metadata, "Model"),
         focal_length: focal_length(metadata),
         aperture: Map.get(metadata, "Aperture"),
         exposure_time: Map.get(metadata, "ExposureTime"),
         iso: Map.get(metadata, "ISO")
       }}
    else
      {:read_file, {:error, error}} -> {:error, {:read_file, error}}
      {:read_metadata, {:error, error}} -> {:error, {:read_metadata, error}}
    end
  end

  # Parses the `DateTimeOriginal` field in EXIF into a `NaiveDateTime`.
  @spec original_datetime(Image.metadata()) :: NaiveDateTime.t() | nil
  defp original_datetime(metadata) do
    with result when result != nil <- Map.get(metadata, "DateTimeOriginal") do
      NaiveDateTime.from_iso8601!(result)
    end
  end

  # Parses the `FocalLength` field in EXIF into a float, discarding the unit measurement.
  # Currently assumes `exiftool` always returns focal length in millimetres, and fails if it doesn't.
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
