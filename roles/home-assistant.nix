{ config, lib, pkgs, ... }:

{
  services.home-assistant = {
    enable = true;
    openFirewall = true;
    package = pkgs.unstable.home-assistant.override {
      extraComponents = [
        "cloud"
        "default_config"
        "lutron_caseta"
        "met"
        "myq"
        "ssdp"
        "tts"
        "updater"
        "zeroconf"
      ];
    };
  };
}
