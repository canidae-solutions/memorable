{
  description = "memories but better";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat.url = "git+https://git.lix.systems/lix-project/flake-compat";

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
        checks.pre-commit = import ./nix/commit-hooks.nix { git-hooks = git-hooks.lib.${system}; };

        devShell = import ./shell.nix {
          inherit pkgs;
          commitHooks = self.checks.${system}.pre-commit;
        };
      }
    );
}
