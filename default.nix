let
  pins = import ./nix/npins;

  nixpkgs = import pins.nixpkgs { };
in

rec {
  rust-lib = (nixpkgs.callPackage ./nix/rust-lib.nix { }).rootCrate.build.lib;

  memorable = nixpkgs.callPackage ./nix/memorable.nix { inherit rust-lib; };
}
