{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.05";
  inputs.nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.kmonad = {
    url = "github:kmonad/kmonad?dir=nix";
    flake = false;
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, flake-utils, kmonad }:
    let
      config = { allowUnfree = true; };
      environments = flake-utils.lib.eachDefaultSystem (system: rec {
        packages = import ./environments {
          stable = import nixpkgs { inherit config system; };
          unstable = import nixpkgs-unstable { inherit config system; };
        };
        legacyPackages = packages;
        defaultPackage = packages.all-env;
      });

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
        nixosConfigurations.iroh = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            (import ./hosts/iroh.nix kmonad)
            ./roles/desktop.nix
            flakeSupport
          ];
        };

        nixosConfigurations.poki = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ ./hosts/poki.nix ./roles/desktop.nix flakeSupport ];
        };

        nixosConfigurations.tenzin = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ ./hosts/tenzin.nix ./roles/desktop.nix flakeSupport ];
        };

        nixosConfigurations.petrus = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          modules = [
            ./hosts/petrus.nix
            ./roles/nas.nix
            ./roles/nextcloud.nix
            ./roles/gitea.nix
            ./roles/bitwarden_rs.nix
            flakeSupport
          ];
        };
      };
    in environments // hosts;
}
