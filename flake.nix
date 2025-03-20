{
  description = "memories but better";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat.url = "github:edolstra/flake-compat";

    git-hooks.url = "github:cachix/git-hooks.nix";
    git-hooks.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      git-hooks,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        checks.pre-commit-check = git-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            mix-format.enable = true;
            nixfmt-rfc-style.enable = true;
          };
        };

        devShell = import ./shell.nix {
          inherit pkgs;
          preCommitHook = self.checks.${system}.pre-commit-check.shellHook;
        };
      }
    );
}
