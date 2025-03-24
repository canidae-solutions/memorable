{ pkgs, lib }:

let
  pins = import ./npins;
  fenix = pkgs.callPackage pins.fenix { };

  toolchainChannel = (lib.importTOML ../rust-toolchain.toml).toolchain.channel;
in
fenix.fromToolchainName {
  name = toolchainChannel;
  sha256 = "sha256-Hn2uaQzRLidAWpfmRwSRdImifGUCAb9HeAqTYFXWeQk=";
}
