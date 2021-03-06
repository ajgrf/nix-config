# This file contains options specific to my RockPro64 installation.
{ config, lib, pkgs, ... }:

{
  # RockPro64 -> rock -> Peter -> petrus.
  networking.hostName = "petrus"; # Define your hostname.

  # Enable non-free firmware.
  hardware.enableRedistributableFirmware = true;

  # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;

  # The serial ports listed here are:
  # - ttyS0: for Tegra (Jetson TX1)
  # - ttyAMA0: for QEMU's -machine virt
  # Also increase the amount of CMA to ensure the virtual console on the RPi3 works.
  boot.kernelParams = [
    "cma=32M"
    "console=ttyS0,115200n8"
    "console=ttyAMA0,115200n8"
    "console=tty0"
  ];

  boot.kernelPackages = pkgs.linuxPackages_5_10;
  boot.initrd.availableKernelModules = [ "ahci" "usbhid" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS_SD";
    fsType = "ext4";
  };

  fileSystems."/home" = {
    device = "/dev/sda1";
    fsType = "btrfs";
    options = [ "subvol=@home" ];
  };

  fileSystems."/depot" = {
    device = "/dev/sda1";
    fsType = "btrfs";
    options = [ "subvol=@depot" ];
  };

  fileSystems."/var/lib/nextcloud" = {
    device = "/dev/sda1";
    fsType = "btrfs";
    options = [ "subvol=@nextcloud" ];
  };

  fileSystems."/var/lib/gitea" = {
    device = "/dev/sda1";
    fsType = "btrfs";
    options = [ "subvol=@gitea" ];
  };

  swapDevices = [ ];

  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";

  # Adjust fan speed by system load.
  hardware.fancontrol.enable = true;
  # hwmon device numbers are not stable between boots. Workaround courtesy of:
  # https://wiki.archlinux.org/index.php/Fan_speed_control#Device_Paths_have_Changed_in_/etc/fancontrol
  hardware.fancontrol.config = ''
    INTERVAL=10
    FCTEMPS=/sys/devices/platform/pwm-fan/hwmon/[[:print:]]*/pwm1=/sys/class/thermal/thermal_zone0/temp
    MINTEMP=/sys/devices/platform/pwm-fan/hwmon/[[:print:]]*/pwm1=40
    MAXTEMP=/sys/devices/platform/pwm-fan/hwmon/[[:print:]]*/pwm1=60
    MINSTART=/sys/devices/platform/pwm-fan/hwmon/[[:print:]]*/pwm1=50
    MINSTOP=/sys/devices/platform/pwm-fan/hwmon/[[:print:]]*/pwm1=50
  '';

  # Repair network connection when ethernet crashes.
  systemd.services.network-repair = {
    description = "repair network connection";
    serviceConfig = {
      Type = "simple";
      ExecStart = (pkgs.writeShellScript "network-repair" ''
        if ! ${pkgs.iputils}/bin/ping -c 1 192.168.1.1 >/dev/null 2>&1; then
            ${pkgs.kmod}/bin/rmmod dwmac_rk
            ${pkgs.coreutils}/bin/sleep 60
            ${pkgs.kmod}/bin/modprobe dwmac_rk
        fi
      '');
    };
  };

  systemd.timers.network-repair = {
    description = "repair network connection";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "3min";
      OnUnitActiveSec = "3min";
    };
  };

  # Spin down hard disks after 10 minutes of idle time.
  systemd.services.hd-idle = {
    description = "hard disk idle spindown";
    # disabled
    # wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart =
        "${pkgs.hd-idle}/bin/hd-idle -d -i 0 -a sda -i 600 -a sdb -i 600";
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?

}
