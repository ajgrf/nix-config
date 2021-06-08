# This file contains common options I want on all my desktop machines.
{ config, pkgs, ... }:

{
  # Select internationalisation properties.
  i18n.defaultLocale = "es_US.UTF-8";

  # Run tzupdate service to auto-detect the time zone.
  services.tzupdate.enable = true;

  # Use NetworkManager to configure network interfaces.
  networking.networkmanager.enable = true;

  # Use DoH (DNS-over-HTTPS) proxy from NextDNS.
  # Run `nextdns config set -config abcdef` to set the configuration ID.
  services.nextdns.enable = true;
  networking.nameservers = [ "127.0.0.1" "::1" ];
  networking.resolvconf.useLocalResolver = true;
  networking.networkmanager.dns = "none";

  # Open KDE Connect ports in the firewall.
  networking.firewall = {
    allowedTCPPortRanges = [{
      from = 1714;
      to = 1764;
    }];
    allowedUDPPortRanges = [{
      from = 1714;
      to = 1764;
    }];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    ark
    gnome.gnome-disk-utility
    gwenview
    kdeconnect
    marble
    okular
    vim
  ];

  # Fonts to make available system-wide.
  fonts.fonts = with pkgs; [ source-han-mono source-han-sans source-han-serif ];

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Magic VPN service. Authenticate with `sudo tailscale up`.
  services.tailscale.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable Bluetooth.
  hardware.bluetooth.enable = true;

  # 32-bit graphics & sound support for games.
  hardware.opengl.driSupport32Bit = true;
  hardware.opengl.extraPackages32 = with pkgs.pkgsi686Linux; [ libva ];
  hardware.pulseaudio.support32Bit = true;

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    libinput.enable = true;

    layout = "us";
    xkbOptions = builtins.concatStringsSep "," [
      "caps:ctrl_modifier"
      "lv3:ralt_alt"
      "compose:menu"
      "shift:both_capslock_cancel"
    ];

    desktopManager.plasma5.enable = true;
    displayManager = {
      sddm.enable = true;
      autoLogin.enable = true;
      autoLogin.user = "ajgrf";
    };
  };

  # Install ADB Android Debug Bridge.
  programs.adb.enable = true;

  # Enable GnuPG agent with socket-activation for every user session.
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryFlavor = "qt";
  };

  # Enable libvirt daemon.
  virtualisation.libvirtd.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.ajgrf = {
    description = "Alex Griffin";
    isNormalUser = true;
    extraGroups = [ "wheel" "libvirtd" "networkmanager" "adbusers" ];
    uid = 1000;
  };

}
