{ config, lib, pkgs, ... }:

{
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud20;
    hostName = "${config.networking.hostName}";

    config = {
      # Nextcloud PostegreSQL database configuration, recommended over using SQLite
      dbtype = "pgsql";
      dbuser = "nextcloud";
      dbhost = "/run/postgresql";
      dbname = "nextcloud";
      dbpassFile = "${config.services.nextcloud.home}/dbpass";

      adminuser = "admin";
      adminpassFile = "${config.services.nextcloud.home}/adminpass";
    };
  };

  # Make Nextcloud accessible by IP address.
  services.nginx.virtualHosts."${config.services.nextcloud.hostName}".default = true;
  services.nextcloud.config.extraTrustedDomains = [ "*" ];

  services.postgresql = {
    enable = true;
    ensureDatabases = [ "nextcloud" ];
    ensureUsers = [
      { name = "nextcloud";
        ensurePermissions."DATABASE nextcloud" = "ALL PRIVILEGES";
      }
    ];
  };

  # Ensure that postgres is running *before* running the setup.
  systemd.services."nextcloud-setup" = {
    requires = [ "postgresql.service" ];
    after = [ "postgresql.service" ];
  };

  # Back up nightly database dumps.
  services.postgresqlBackup = {
    enable = true;
    location = "/depot/backup/postgresql";
    startAt = "*-*-* 00:00:00";
  };

  # Back up Nextcloud data.
  services.restic.backups."nextcloud" = {
    passwordFile = "/etc/nixos/restic-password";
    paths = [
      config.services.nextcloud.home
      config.services.postgresqlBackup.location
    ];
    repository = "s3:s3.us-west-001.backblazeb2.com/ajgbackup/restic";
    s3CredentialsFile = "/etc/nixos/restic-s3creds";
    timerConfig = { OnCalendar = "*-*-* 00:00:15"; };
  };
}
