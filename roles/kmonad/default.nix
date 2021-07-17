kmonad:
{ config, lib, pkgs, ... }:

let kmonadPkg = import "${kmonad}/nix/kmonad.nix";
in {
  imports = [ "${kmonad}/nix/nixos-module.nix" ];

  services.kmonad = {
    enable = true;
    package = with pkgs.haskellPackages; callPackage kmonadPkg { };
    configfiles = [ ./cleave.kbd ];
  };
}
