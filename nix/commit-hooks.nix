let
  pins = import ./npins;
in

{
  pkgs,
  git-hooks ? import pins.git-hooks,
}:

git-hooks.run {
  src = ./..;
  hooks = {
    mix-format.enable = true;
    nixfmt-rfc-style.enable = true;
  };

  tools = {
    inherit (pkgs) elixir nixfmt-rfc-style;
  };
}
