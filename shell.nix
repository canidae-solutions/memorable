let
  pins = import ./nix/npins;

  nixpkgs = import pins.nixpkgs { };
  commitHooks = import ./nix/commit-hooks.nix { pkgs = nixpkgs; };
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
