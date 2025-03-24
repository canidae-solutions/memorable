let
  pins = import ./nix/npins;

  nixpkgs = import pins.nixpkgs { };
  rust-toolchain = import ./nix/rust-toolchain.nix nixpkgs;

  buildRustCrateForPkgs =
    pkgs:
    pkgs.buildRustCrate.override {
      inherit (rust-toolchain) rustc cargo;
    };
in

rec {
  rust-lib =
    (nixpkgs.callPackage ./nix/rust-lib.nix {
      inherit buildRustCrateForPkgs;
    }).rootCrate.build.lib;

  memorable = nixpkgs.callPackage ./nix/memorable.nix { inherit rust-lib; };
}
