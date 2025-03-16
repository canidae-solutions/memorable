{
  pkgs ? import <nixpkgs> { },
}:

pkgs.mkShell {
  name = "memorable-dev-shell";

  packages = with pkgs; [
    elixir
    elixir-ls
  ];
}
