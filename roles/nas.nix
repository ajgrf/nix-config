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

  # Back up nightly database dumps.
  services.postgresqlBackup = {
    enable = true;
    location = "/depot/backup/postgresql";
    startAt = "*-*-* 00:00:00";
  };

  # Back up Nextcloud data.
  services.restic.backups."${config.networking.hostName}" = {
    passwordFile = "/etc/nixos/restic-password";
    paths = [ config.services.postgresqlBackup.location ];
    repository = "s3:s3.us-west-001.backblazeb2.com/ajgbackup/restic";
    s3CredentialsFile = "/etc/nixos/restic-s3creds";
    timerConfig = { OnCalendar = "*-*-* 00:00:15"; };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.ajgrf = {
    description = "Alex Griffin";
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    uid = 1000;
  };

}
