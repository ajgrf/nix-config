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

      hosts.iroh.modules = [
        ./hosts/iroh.nix
        ./modules/desktop.nix
        (import ./modules/kmonad kmonad)
      ];

      hosts.poki.modules = [ ./hosts/poki.nix ./modules/desktop.nix ];

      hosts.tenzin.modules = [ ./hosts/tenzin.nix ./modules/desktop.nix ];

      hosts.petrus = {
        system = "aarch64-linux";
        modules = [ ./hosts/petrus.nix ./modules/nas ];
      };

      # Nix REPL for exploring this flake:
      # https://github.com/NixOS/nix/issues/3803#issuecomment-748612294
      appsBuilder = channels:
        with channels.nixpkgs; {
          repl = flake-utils-plus.lib.mkApp {
            drv = pkgs.writeShellScriptBin "repl" ''
              confnix=$(mktemp)
              echo "builtins.getFlake (toString $(git rev-parse --show-toplevel))" >$confnix
              trap "rm $confnix" EXIT
              nix repl $confnix
            '';
          };
        };
    };
}
