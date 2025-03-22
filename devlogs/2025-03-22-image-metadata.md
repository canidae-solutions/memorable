# 2025-03-22: image metadata

## derived image metadata

images currently have little more metadata than what was supported by memories: a path (`path`), a “birth” time or time the photo was taken (`timestamp`), tags (`ImageTag`), and now a collection (`collection_id`) and time the photo was imported (`upload_date`).

there’s a lot more metadata out there, much of which is in the exif tags, but not all metadata should necessarily go in the database. so how do we decide?

we could say none of the exif data should be in the database, because it’s redundant, strictly speaking. but then if we want to search for photos with a particular lens or exposure time, we need to read every photo from disk, parsing exif data over and over.

we could say all of the exif data should be in the database, since we might need it later. but a generic approach like that has questionable benefit. exif data varies heavily from vendor to vendor, even in the output of tools like exiftool(1), so it almost always needs further interpretation to be useful. and the only ways to store this data without domain-specific logic are to pack it into a column (not indexable), make a column for each tag (extremely wide records), or use a dreaded eav data model (there are many, many reasons [why this is a bad idea](https://www.cedanet.com.au/antipatterns/eav.php)).

so it seems more appropriate to say any exif data we care to search for (or otherwise retrieve efficiently) should also be in the database, added on a case-by-case basis. for example:

| field         | ideal type   | potential search queries           |
|---------------|--------------|------------------------------------|
| lens_model    | string       | `lens:70-300`, `lens:"55-250 stm"` |
| body_model    | string       | `body:d3200`, `body:"x-t30 ii"`    |
| focal_length  | real (mm)    | `focal_length:70`, `...:>100`      |
| aperture      | rational     | `aperture:1/4`, `aperture:>1/2.8`  |
| exposure_time | rational (s) |
| iso           | real         |

all of these metadata are kinda like a cache over the exif data, so for data integrity reasons, we’ll want to “ground” that against the file they came from somehow, in case the file gets swapped out or damaged. we can probably use a hash of the file.

if we put this “cached” or “derived” metadata in its own table, then we can control its storage separately from unique data, for example by not persisting it to disk. this also makes it clearer that such data can be discarded and refreshed at any time.

## the rest of the image data model

`path` is “relative to image directory”. what is the image directory? are our images imported in place, or do we have a dedicated image store, or both?

datetime instants like `timestamp` and `upload_date` should probably be named consistently. either `_time`, `_date`, `_datetime`, or `when_`, that kinda thing. each of their names should indicate what event they are for, so `timestamp` would be `original_datetime` per exif (and would be moved to the derived table).

we might want to rename `upload_datetime` to `import_datetime`, since you might import an image without uploading it.
