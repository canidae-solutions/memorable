let
  pins = import ./nix/npins;

  nixpkgs = import pins.nixpkgs { };
  crate2nix = nixpkgs.callPackage pins.crate2nix { };
  commitHooks = nixpkgs.callPackage ./nix/commit-hooks.nix { inherit crate2nix; };
  rust-toolchain = nixpkgs.callPackage ./nix/rust-toolchain.nix { };
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
    nixfmt-rfc-style
    nil
    npins

    rust-toolchain.cargo
    rust-toolchain.rustc
    exiftool
  ];

  inherit (commitHooks) shellHook;
}
