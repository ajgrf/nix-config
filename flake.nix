{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-20.09";
  inputs.nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, nixpkgs-unstable, flake-utils }:
    let
      environments = flake-utils.lib.eachDefaultSystem (system:
        let
          config = {
            allowUnfree = true;
          };
          pkgImport = pkgs: import pkgs { inherit config system; };
        in
          rec {
            packages = import ./environments {
              stable = pkgImport nixpkgs;
              unstable = pkgImport nixpkgs-unstable;
            };
            legacyPackages = packages;
            defaultPackage = packages.all-env;
          }
      );

      flakeSupport = ({ lib, pkgs, ... }: {
        # Enable flake support.
        nix.package = pkgs.nixFlakes;
        nix.extraOptions = ''
          experimental-features = nix-command flakes ca-references
        '';
        # Let 'nixos-version --json' know about the Git revision
        # of this flake.
        system.configurationRevision = lib.mkIf (self ? rev) self.rev;
      });

      hosts = {
        nixosConfigurations.poki = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/poki.nix
            ./roles/desktop.nix
            flakeSupport
          ];
        };

        nixosConfigurations.tenzin = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/tenzin.nix
            ./roles/desktop.nix
            flakeSupport
          ];
        };

        nixosConfigurations.petrus = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          modules = [
            ./hosts/petrus.nix
            ./roles/nas.nix
            ./roles/nextcloud.nix
            ./roles/gitea.nix
            flakeSupport
          ];
        };
      };
    in
      environments // hosts;
}
