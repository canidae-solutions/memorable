defmodule Memorable.Data.ImageTest do
  use ExUnit.Case
  alias Memorable.Data.Image
  alias Memorable.Data.Image.DerivedMetadata
  doctest Memorable.Data.Image

  setup_all do
    on_exit(fn ->
      Memento.Table.clear(Image)
    end)

    # `Command` in rust needs to call waitpid(2), which fails with ECHILD when the signal handler
    # for SIGCHLD is set to SIG_IGN, as is done in the erlang vm.
    # <https://github.com/rusterlium/rustler/issues/446>
    # <http://erlang.org/pipermail/erlang-questions/2020-November/100109.html>
    :os.set_signal(:sigchld, :default)

    [
      image: %Image{
        id: 1,
        collection_id: nil,
        path: "test/data/20250317_0_0028_01.jpg",
        imported_datetime: DateTime.utc_now()
      }
    ]
  end

  describe "Image.read_metadata/1" do
    test "dumps exif data for the given image", %{image: image} do
      {:ok, metadata} = Image.read_metadata(image)
      assert Map.get(metadata, "DateTimeOriginal") == "2025-03-17T18:38:23"
      assert Map.get(metadata, "Model") == "Canon EOS 1000D"
      assert Map.get(metadata, "LensID") == "Canon EF-S 55-250mm f/4-5.6 IS STM"
      assert Map.get(metadata, "FocalLength") == "250.0 mm"
      assert Map.get(metadata, "Aperture") == 5.6
      assert Map.get(metadata, "ExposureTime") == "1/1250"
      assert Map.get(metadata, "ISO") == 100
    end
  end

  describe "DerivedMetadata.from_image/1" do
    test "parses exif data for the given image", %{image: image} do
      {:ok, metadata} = DerivedMetadata.from_image(image) |> IO.inspect()
      assert Map.get(metadata, :image_id) == Map.get(image, :id)

      assert Map.get(metadata, :file_hash) ==
               {:sha256, "3932e8b3f41678e215981303d8320ab70c00fd35b0e8f063eec3087c7de801df"}

      assert Map.get(metadata, :original_datetime) == ~N[2025-03-17 18:38:23]
      assert Map.get(metadata, :body_model) == "Canon EOS 1000D"
      assert Map.get(metadata, :lens_model) == "Canon EF-S 55-250mm f/4-5.6 IS STM"
      assert Map.get(metadata, :focal_length) == 250.0
      assert Map.get(metadata, :aperture) == 5.6
      assert Map.get(metadata, :exposure_time) == "1/1250"
      assert Map.get(metadata, :iso) == 100
    end
  end
end
