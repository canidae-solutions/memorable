let
  pins = import ./nix/npins;

  nixpkgs = import pins.nixpkgs { };
  commitHooks = nixpkgs.callPackage ./nix/commit-hooks.nix { };
  crate2nix = nixpkgs.callPackage pins.crate2nix { };
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
    nixfmt-rfc-style
    nil
    npins

    rustup
    exiftool
  ];

  inherit (commitHooks) shellHook;
}
