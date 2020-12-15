{ config, lib, pkgs, ... }:

{
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud20;
    hostName = "nextcloud";

    # Automatically update apps from the Nextcloud app store.
    autoUpdateApps.enable = true;
    autoUpdateApps.startAt = "Sun 06:00:00";

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

  # Allow admin access from any domain or IP address.
  services.nextcloud.config.extraTrustedDomains = [ "*" ];
  # Serve Nextcloud by default.
  services.nginx.virtualHosts = {
    nextcloud.listen = [ { addr = "127.0.0.1"; port = 4000; } ];
    localhost.locations."/".proxyPass = "http://localhost:4000/";
  };

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

  # Back up Nextcloud data.
  services.restic.backups."${config.networking.hostName}".paths = [
    config.services.nextcloud.home
  ];
}
