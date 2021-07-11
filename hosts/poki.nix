# This file contains options specific to my System76 Lemur Pro installation.
{ config, lib, pkgs, ... }:

{
  # Named after Meelo's lemur in The Legend of Korra.
  networking.hostName = "poki";

  # Bootloader settings.
  boot.loader = {
    timeout = 2;
    systemd-boot.enable = true;
    efi = {
      efiSysMountPoint = "/boot/efi";
      canTouchEfiVariables = true;
    };
  };

  # Enable non-free firmware.
  hardware.enableRedistributableFirmware = true;

  # Enable System76 kernel modules and firmware daemon.
  hardware.system76.enableAll = true;
  # Include firmware update utility as well.
  environment.systemPackages = with pkgs; [ firmware-manager ];

  # Edited results of the hardware scan (nixos-generate-config):

  boot.initrd.availableKernelModules =
    [ "xhci_pci" "nvme" "usbhid" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/291dd1c2-8a75-405b-80c1-5fe286699e66";
    fsType = "btrfs";
    options = [ "subvol=@nixos" "compress=zstd" ];
  };

  boot.initrd.luks.devices."cryptvol".device =
    "/dev/disk/by-uuid/5382c961-005d-4aaf-921e-ad05cf04d754";

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/291dd1c2-8a75-405b-80c1-5fe286699e66";
    fsType = "btrfs";
    options = [ "subvol=@nix-store" "compress=zstd" ];
  };

  fileSystems."/boot/efi" = {
    device = "/dev/disk/by-uuid/D282-B1CE";
    fsType = "vfat";
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/291dd1c2-8a75-405b-80c1-5fe286699e66";
    fsType = "btrfs";
    options = [ "subvol=@home" "compress=zstd" ];
  };

  fileSystems."/swap" = {
    device = "/dev/disk/by-uuid/291dd1c2-8a75-405b-80c1-5fe286699e66";
    fsType = "btrfs";
    options = [ "subvol=@swap" ];
  };

  swapDevices = [{ device = "/swap/swapfile"; }];

  nix.maxJobs = lib.mkDefault 8;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?

}
