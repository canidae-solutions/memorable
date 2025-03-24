let
  pins = import ./nix/npins;

  nixpkgs = import pins.nixpkgs { };
in

{
  pkgs ? nixpkgs,
  commitHooks ? import ./nix/commit-hooks.nix { inherit pkgs; },
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
