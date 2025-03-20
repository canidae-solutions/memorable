{
  pkgs ? import <nixpkgs> { },
  preCommitHook ? "",
}:

pkgs.mkShell {
  name = "memorable-dev-shell";

  packages = with pkgs; [
    elixir
    elixir-ls

    nixfmt-rfc-style
    nil
  ];

  shellHook = ''
    ${preCommitHook}
  '';
}
