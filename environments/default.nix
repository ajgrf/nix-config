{ stable, unstable, ... }:

with stable.pkgs; rec {
  inherit unstable;

  all-env = buildEnv {
    name = "all-env";
    paths = [
      apps-env
      emacs-env
      fonts-env
      games-env
      tools-env
    ];
  };

  minimal-env = buildEnv {
    name = "minimal-env";
    paths = [
      emacs-env
      tools-env
    ];
  };

  apps-env = buildEnv {
    name = "apps-env";
    extraOutputsToInstall = [ "doc" "man" ];
    paths = [
      unstable.alacritty
      unstable.anki-bin
      celluloid
      bitwarden
      brave
      feh
      firefox
      gnome3.gnome-boxes
      gnome3.gnome-tweaks
      libreoffice
      lollypop
      mpv
      nextcloud-client
      # quodlibet
      signal-desktop
      spotify
      thunderbird
      # tor-browser-bundle-bin
      transmission-gtk
      virt-manager
      xclip
      xdotool
      xorg.xrdb
      xterm
    ];
  };

  emacs-env = buildEnv {
    name = "emacs-env";
    extraOutputsToInstall = [ "doc" "man" ];
    paths = [
      (aspellWithDicts (dicts: with dicts; [ en en-computers en-science ]))
      (with unstable; (emacsPackagesGen emacs).emacsWithPackages (epkgs: [
        epkgs.vterm
        epkgs.pdf-tools
      ]))
      fd
      git
      ripgrep
    ];
  };

  fonts-env = buildEnv {
    name = "fonts-env";
    paths = [
      go-font
      iosevka
      (iosevka.override { set = "aile"; })
      (iosevka.override { set = "slab"; })
    ];
  };

  games-env = buildEnv {
    name = "games-env";
    extraOutputsToInstall = [ "doc" "man" ];
    paths = [
      crispyDoom
      dosbox
      lutris
      openmw
      scummvm
      steam
    ];
  };

  tools-env = buildEnv {
    name = "tools-env";
    extraOutputsToInstall = [ "doc" "man" ];
    paths = [
      aria2
      bitwarden-cli
      brightnessctl
      direnv
      ffmpeg
      file
      git
      gitAndTools.git-annex
      gitAndTools.git-annex-remote-rclone
      gnupg
      imagemagick
      ledger
      libnotify
      moreutils
      unstable.protonmail-bridge
      rclone
      reptyr
      restic
      rsync
      shellcheck
      shfmt
      stow
      tmux
      topgrade
      trash-cli
      youtube-dl
    ];
  };
}
