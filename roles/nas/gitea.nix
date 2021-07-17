{ config, lib, pkgs, ... }:

{
  services.gitea = {
    enable = true;
    appName = "${config.networking.hostName}: Gitea Service";
    rootUrl = "http://${config.networking.hostName}:3000/git/";

    database = {
      type = "postgres";
      passwordFile = "${config.services.gitea.stateDir}/dbpass";
    };
  };

  services.postgresql = {
    enable = true;
    authentication = "local gitea all ident map=gitea-users";
    identMap = "gitea-users gitea gitea";
  };

  # Serve Gitea under /git subdirectory.
  services.nginx.virtualHosts = {
    localhost.locations."^~ /git/".proxyPass = "http://localhost:3000/";
  };

  # Back up Gitea data.
  services.restic.backups."${config.networking.hostName}".paths =
    [ config.services.gitea.stateDir ];
}
