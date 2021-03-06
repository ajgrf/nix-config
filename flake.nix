{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.05";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    utils.url = "github:gytis-ivaskevicius/flake-utils-plus";

    kmonad = {
      url = "github:kmonad/kmonad?dir=nix";
      flake = false;
    };
  };

  outputs = inputs@{ self, nixpkgs, unstable, utils, kmonad, ... }:
    with (import ./modules { inherit utils; });
    utils.lib.systemFlake {
      inherit self inputs;

      channelsConfig.allowUnfree = true;

      channels.nixpkgs.input = nixpkgs;
      channels.unstable.input = unstable;

      overlay = import ./overlays;
      sharedOverlays = [ self.overlay ];

      packagesBuilder = { nixpkgs, unstable, ... }:
        import ./environments { inherit nixpkgs unstable; };

      hostDefaults = {
        system = "x86_64-linux";
        modules = [ utils.nixosModules.saneFlakeDefaults ];
        # These are not part of the module system, so they can be used in
        # `imports` lines without infinite recursion.
        specialArgs = { inherit kmonad; };
      };

      hosts.iroh.modules = [ iroh desktop ];

      hosts.poki.modules = [ poki desktop ];

      hosts.tenzin.modules = [ tenzin desktop ];

      hosts.petrus = {
        system = "aarch64-linux";
        modules = [ petrus nas ];
      };

      # Nix REPL for exploring this flake:
      # https://github.com/NixOS/nix/issues/3803#issuecomment-748612294
      appsBuilder = channels:
        with channels.nixpkgs; {
          repl = utils.lib.mkApp {
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
