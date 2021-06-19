{ config, lib, pkgs, ... }:

{
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud21;
    hostName = "localhost";

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

  # Set up CORS headers for organice.
  services.nginx.virtualHosts.localhost.locations = {
    "~ ^\\/(?:index|remote|public|cron|core\\/ajax\\/update|status|ocs\\/v[12]|updater\\/.+|oc[ms]-provider\\/.+|.+\\/richdocumentscode\\/proxy)\\.php(?:$|\\/)".extraConfig =
      ''
        # Duplicated from virtualHost extraConfig
        add_header X-Content-Type-Options nosniff;
        add_header X-XSS-Protection "1; mode=block";
        add_header X-Robots-Tag none;
        add_header X-Download-Options noopen;
        add_header X-Permitted-Cross-Domain-Policies none;
        add_header X-Frame-Options sameorigin;
        add_header Referrer-Policy no-referrer;
        add_header Strict-Transport-Security "max-age=15552000; includeSubDomains" always;

        # CORS headers
        add_header 'Access-Control-Allow-Origin' 'https://organice.200ok.ch' always;
        add_header 'Access-Control-Allow-Methods' 'GET, OPTIONS, POST, PROPFIND, PUT' always;
        add_header 'Access-Control-Allow-Headers' 'Authorization,Depth,DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range' always;
        add_header 'Access-Control-Expose-Headers' 'Content-Length,Content-Range' always;
        if ($request_method = 'OPTIONS') {
            return 204;
        }
      '';
  };

  services.postgresql = {
    enable = true;
    ensureDatabases = [ "nextcloud" ];
    ensureUsers = [{
      name = "nextcloud";
      ensurePermissions."DATABASE nextcloud" = "ALL PRIVILEGES";
    }];
  };

  # Ensure that postgres is running *before* running the setup.
  systemd.services."nextcloud-setup" = {
    requires = [ "postgresql.service" ];
    after = [ "postgresql.service" ];
  };

  # Back up Nextcloud data.
  services.restic.backups."${config.networking.hostName}".paths =
    [ config.services.nextcloud.home ];
}
