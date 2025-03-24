{
  lib,
  beamPackages,
  rust-lib,
}:

let
  inherit (beamPackages) mixRelease fetchMixDeps;

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

mixRelease rec {
  pname = "memorable";
  version = "0.1.0";

  inherit src;

  buildInputs = [ rust-lib ];

  IS_NIX_BUILD = 1;
  removeCookie = false;
  mixFodDeps = fetchMixDeps {
    pname = "mix-deps-${pname}";
    inherit version src;
    hash = "sha256-r7SrGgy4py1pFvVBOM5J0IH7MVxpk5K8wi06CtE/WTU=";
    IS_NIX_BUILD = 1;
  };

  postBuild = ''
    mkdir -p priv/native
    ln -s ${rust-lib.lib}/lib/libsubprocess.so priv/native/libsubprocess.so
  '';
}
