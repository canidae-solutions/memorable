let
  pins = import ./npins;
in

{
  git-hooks ? import pins.git-hooks,
}:

git-hooks.run {
  src = ./..;
  hooks = {
    mix-format.enable = true;
    nixfmt-rfc-style.enable = true;
  };
}
