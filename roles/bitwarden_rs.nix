{ config, lib, pkgs, ... }:

{
  services.bitwarden_rs = {
    enable = true;
    backupDir = "/var/backup/bitwarden_rs";
    config = {
      domain = "http://${config.networking.hostName}/bitwarden";
      webVaultEnabled = false;
    };
  };

  # Serve Bitwarden under /bitwarden subdirectory.
  services.nginx.virtualHosts = {
    localhost.locations."^~ /bitwarden/".proxyPass = "http://localhost:8000";
  };

  # Create backup directory with correct permissions.
  system.activationScripts.bitwarden_rs-mkBackupDir = {
    text = ''
      mkdir -p "${config.services.bitwarden_rs.backupDir}"
      chmod 700 "${config.services.bitwarden_rs.backupDir}"
      chown bitwarden_rs:root "${config.services.bitwarden_rs.backupDir}"
    '';
    deps = [];
  };

  # Back up Bitwarden data.
  services.restic.backups."${config.networking.hostName}".paths = [
    config.services.bitwarden_rs.backupDir
  ];
}
