# This file contains options specific to my desktop installation.
kmonad:
{ config, lib, pkgs, ... }:

let kmonadPkg = import "${kmonad}/nix/kmonad.nix";
in {
  imports = [ "${kmonad}/nix/nixos-module.nix" ];

  # Named after "The Dragon of the West".
  networking.hostName = "iroh";

  # Bootloader settings.
  boot.loader = {
    timeout = 2;
    systemd-boot.enable = true;
    efi = {
      efiSysMountPoint = "/boot/efi";
      canTouchEfiVariables = true;
    };
  };

  services.kmonad = {
    enable = true;
    package = with pkgs.haskellPackages; callPackage kmonadPkg { };
    configfiles = [ ../files/cleave.kbd ];
  };

  # Enable non-free firmware.
  hardware.enableRedistributableFirmware = true;

  # Control brightness of external monitors in Plasma desktop.
  services.xserver.desktopManager.plasma5.supportDDC = true;

  # Edited results of the hardware scan (nixos-generate-config):

  boot.initrd.availableKernelModules =
    [ "nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/f9df6fcb-f168-4ec3-adca-0add57ef333b";
    fsType = "btrfs";
    options = [ "subvol=@nixos" "compress=zstd" ];
  };

  boot.initrd.luks.devices."cryptvol".device =
    "/dev/disk/by-uuid/79c464a7-84fd-46c3-a118-0d6312cfc70c";

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/f9df6fcb-f168-4ec3-adca-0add57ef333b";
    fsType = "btrfs";
    options = [ "subvol=@home" "compress=zstd" ];
  };

  fileSystems."/boot/efi" = {
    device = "/dev/disk/by-uuid/4FD7-6F74";
    fsType = "vfat";
  };

  fileSystems."/swap" = {
    device = "/dev/disk/by-uuid/f9df6fcb-f168-4ec3-adca-0add57ef333b";
    fsType = "btrfs";
    options = [ "subvol=@swap" ];
  };

  swapDevices = [{ device = "/swap/swapfile"; }];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?

}
