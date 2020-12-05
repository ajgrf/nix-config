# This file contains options for my NAS machine.
{ config, pkgs, ... }:

{
  # Set your time zone.
  time.timeZone = "US/Central";

  # Use NetworkManager to configure network interfaces.
  networking.networkmanager.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
  ];

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Magic VPN service. Authenticate with `sudo tailscale up`.
  services.tailscale.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.ajgrf = {
    description = "Alex Griffin";
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    uid = 1000;
  };

}
