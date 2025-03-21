let
  inputs = import ./inputs.nix;
in

{
  git-hooks ? inputs.git-hooks.lib,
}:

git-hooks.run {
  src = ./..;
  hooks = {
    mix-format.enable = true;
    nixfmt-rfc-style.enable = true;
  };
}
