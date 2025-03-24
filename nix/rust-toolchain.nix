pkgs:

let
  pins = import ./npins;
  fenix = import pins.fenix { inherit pkgs; };

  toolchainChannel = (pkgs.lib.importTOML ../rust-toolchain.toml).toolchain.channel;
in
fenix.fromToolchainName {
  name = toolchainChannel;
  sha256 = "sha256-Hn2uaQzRLidAWpfmRwSRdImifGUCAb9HeAqTYFXWeQk=";
}
