let
  pins = import ./nix/npins;

  nixpkgs = import pins.nixpkgs { };
  commitHooks = nixpkgs.callPackage ./nix/commit-hooks.nix { };
in

{
  pkgs ? nixpkgs,
}:

pkgs.mkShell {
  name = "memorable-dev-shell";

  packages = with pkgs; [
    elixir
    elixir-ls

    nixfmt-rfc-style
    nil
    npins

    rustup
    exiftool
  ];

  inherit (commitHooks) shellHook;
}
