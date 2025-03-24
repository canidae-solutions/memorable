let
  pins = import ./npins;
in

{
  elixir,
  nixfmt-rfc-style,
  git-hooks ? import pins.git-hooks,
}:

git-hooks.run {
  src = ./..;
  hooks = {
    mix-format.enable = true;

    nixfmt-rfc-style = {
      enable = true;
      excludes = [
        "mix-deps\\.nix$"
        "npins/default\\.nix$"
        "rust-lib\\.nix$"
      ];
    };
  };

  tools = {
    inherit elixir nixfmt-rfc-style;
  };
}
