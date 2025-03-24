let
  pins = import ./npins;
in

{
  lib,
  crate2nix,
  elixir,
  mix2nix,
  nixfmt-rfc-style,

  git-hooks ? import pins.git-hooks,
  rust-toolchain,
}:

git-hooks.run {
  src = ./..;
  hooks = {
    clippy.enable = true;
    rustfmt.enable = true;

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

    regen-rust-lib = {
      enable = true;
      name = "Regen rust-lib.nix";
      entry = "${lib.getExe crate2nix} generate -o nix/rust-lib.nix";
      files = "Cargo\\.lock$";
      pass_filenames = false;
    };
  };

  tools = {
    inherit elixir nixfmt-rfc-style;
    inherit (rust-toolchain) cargo clippy rustfmt;
  };
}
