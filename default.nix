let
  pins = import ./nix/npins;

  nixpkgs = import pins.nixpkgs {
    config = { };
    overlays = [ ];
  };
  rust-toolchain = nixpkgs.callPackage ./nix/rust-toolchain.nix { };

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
