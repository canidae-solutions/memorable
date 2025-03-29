let
  pins = import ./nix/npins;

  nixpkgs = import pins.nixpkgs {
    config = { };
    overlays = [ ];
  };
  crate2nix = nixpkgs.callPackage pins.crate2nix { };
  rust-toolchain = nixpkgs.callPackage ./nix/rust-toolchain.nix { };
  commitHooks = nixpkgs.callPackage ./nix/commit-hooks.nix { inherit crate2nix rust-toolchain; };
in

{
  pkgs ? nixpkgs,
}:

pkgs.mkShell {
  name = "memorable-dev-shell";

  packages = with pkgs; [
    elixir
    elixir-ls

    crate2nix
    mix2nix
    nixd
    nixfmt-rfc-style
    npins

    rust-toolchain.defaultToolchain
    rust-toolchain.rust-analyzer

    exiftool
  ];

  RUST_SRC_PATH = "${rust-toolchain.rust-src}/lib/rustlib/src/rust/library/";

  inherit (commitHooks) shellHook;
}
