let
  lock = builtins.fromJSON (builtins.readFile ../flake.lock);

  flake-compat =
    let
      inherit (lock.nodes.flake-compat.locked) narHash rev url;
    in
    import (fetchTarball {
      url = "${url}/archive/${rev}.tar.gz";
      sha256 = narHash;
    });

  flake = flake-compat { src = ./..; };

  flattenInput = builtins.mapAttrs (
    _: attr:
    let
      system = builtins.currentSystem;
      hasSystem = builtins.isAttrs attr && attr ? ${system};
    in
    if hasSystem then attr.${system} else attr
  );
in
builtins.mapAttrs (_: input: flattenInput input) flake.inputs
