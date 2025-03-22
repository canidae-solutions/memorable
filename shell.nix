let
  inputs = import ./nix/inputs.nix;
in

{
  pkgs ? inputs.nixpkgs.legacyPackages,
  commitHooks ? import ./nix/commit-hooks.nix { },
}:

pkgs.mkShell {
  name = "memorable-dev-shell";

  packages = with pkgs; [
    elixir
    elixir-ls

    nixfmt-rfc-style
    nil

    cargo
    exiftool
  ];

  inherit (commitHooks) shellHook;
}
