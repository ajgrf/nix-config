{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.05";
  inputs.nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.flake-utils-plus.url = "github:gytis-ivaskevicius/flake-utils-plus";
  inputs.kmonad = {
    url = "github:kmonad/kmonad?dir=nix";
    flake = false;
  };

  outputs =
    inputs@{ self, nixpkgs, nixpkgs-unstable, flake-utils-plus, kmonad }:
    flake-utils-plus.lib.systemFlake {
      inherit self inputs;

      channelsConfig.allowUnfree = true;

      channels.nixpkgs.input = nixpkgs;
      channels.nixpkgs-unstable.input = nixpkgs-unstable;

      packagesBuilder = { nixpkgs, nixpkgs-unstable, ... }:
        import ./environments {
          stable = nixpkgs;
          unstable = nixpkgs-unstable;
        };

      hostDefaults = {
        system = "x86_64-linux";
        modules = [ flake-utils-plus.nixosModules.saneFlakeDefaults ];
      };

      hosts.iroh.modules =
        [ ./hosts/iroh.nix ./roles/desktop.nix (import ./roles/kmonad kmonad) ];

      hosts.poki.modules = [ ./hosts/poki.nix ./roles/desktop.nix ];

      hosts.tenzin.modules = [ ./hosts/tenzin.nix ./roles/desktop.nix ];

      hosts.petrus = {
        system = "aarch64-linux";
        modules = [ ./hosts/petrus.nix ./roles/nas ];
      };
    };
}
