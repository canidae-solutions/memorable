let
  pins = import ./nix/npins;

  nixpkgs = import pins.nixpkgs { };
in

{
  rust-lib = (nixpkgs.callPackage ./nix/rust-lib.nix { }).rootCrate.build.lib;
}
