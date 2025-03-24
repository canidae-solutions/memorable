{
  lib,
  beamPackages,
  rust-lib,
}:

let
  fs = lib.fileset;
  fileset = fs.intersection (fs.gitTracked ../.) (
    fs.unions [
      ../config
      ../lib
      ../mix.exs
      ../mix.lock
      ../test
    ]
  );

  src = fs.toSource {
    root = ../.;
    inherit fileset;
  };
in

beamPackages.mixRelease {
  pname = "memorable";
  version = "0.1.0";

  inherit src;

  buildInputs = [ rust-lib ];

  IS_NIX_BUILD = 1;
  removeCookie = false;
  mixNixDeps = import ./mix-deps.nix {
    inherit beamPackages lib;
  };

  postBuild = ''
    mkdir -p priv/native
    ln -s ${rust-lib.lib}/lib/libsubprocess.so priv/native/libsubprocess.so
  '';
}
