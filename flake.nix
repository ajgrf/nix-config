{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-20.09";

  outputs = { self, nixpkgs }:
    let
      flakeSupport =
        ({ lib, pkgs, ... }: {
          # Enable flake support.
          nix.package = pkgs.nixFlakes;
          nix.extraOptions = ''
            experimental-features = nix-command flakes ca-references
          '';
          # Let 'nixos-version --json' know about the Git revision
          # of this flake.
          system.configurationRevision = lib.mkIf (self ? rev) self.rev;
        });
    in
      {
        nixosConfigurations.poki = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/poki.nix
            ./roles/desktop.nix
            flakeSupport
          ];
        };
      };
}
