{
  description = "Agimus Dev Containers";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;
      perSystem =
        {
          pkgs,
          self',
          system,
          ...
        }:
        {
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            # remote-containers won't run on vscodium.
            # also, NVidia.
            config.allowUnfree = true;
          };
          devShells.default = pkgs.mkShell {
            packages = [
              pkgs.cudaPackages.cudatoolkit
              self'.packages.vscode
            ];
          };
          packages = {
            vscode = pkgs.vscode-with-extensions.override {
              vscodeExtensions = with pkgs.vscode-extensions.ms-vscode-remote; [
                remote-containers
              ];
            };
          };
        };
    };
}
