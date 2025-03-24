let
  pins = import ./npins;
in

{
  lib,
  elixir,
  mix2nix,
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

    regen-mix-deps = {
      enable = true;
      name = "Regen mix-deps.nix";
      entry = "bash -c '${lib.getExe mix2nix} mix.lock > nix/mix-deps.nix'";
      files = "mix\\.lock$";
      pass_filenames = false;
    };
  };

  tools = {
    inherit elixir nixfmt-rfc-style;
  };
}
