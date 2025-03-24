lib:

let
  fs = lib.fileset;
  fileset = fs.intersection (fs.gitTracked ../.) (
    fs.unions [
      ../config
      ../lib
      ../mix.exs
      ../mix.lock
      ../README.md
      ../test
    ]
  );

in
fs.toSource {
  root = ../.;
  inherit fileset;
}
