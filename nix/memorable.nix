{
  lib,
  beamPackages,
  rust-lib,
}:

beamPackages.mixRelease {
  pname = "memorable";
  version = "0.1.0";

  src = import ./memorable-src.nix lib;

  buildInputs = [ rust-lib ];

  IS_NIX_BUILD = 1;
  removeCookie = false;
  mixNixDeps = import ./mix-deps.nix {
    inherit beamPackages lib;
  };

  outputs = [
    "out"
    "doc"
  ];

  postBuild = ''
    mkdir -p priv/native
    ln -s ${rust-lib.lib}/lib/libsubprocess.so priv/native/libsubprocess.so

    mix do deps.loadpaths --no-deps-check, docs
  '';

  postInstall = ''
    mv doc $doc
  '';
}
