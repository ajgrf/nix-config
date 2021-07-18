{ nixpkgs, unstable, ... }:

with nixpkgs.pkgs; rec {
  inherit unstable;

  all-env = buildEnv {
    name = "all-env";
    paths = [ apps-env emacs-env fonts-env games-env tools-env ];
  };

  minimal-env = buildEnv {
    name = "minimal-env";
    paths = [ emacs-env tools-env ];
  };

  wsl-env = buildEnv {
    name = "wsl-env";
    paths = [ minimal-env wslu ];
  };

  apps-env = buildEnv {
    name = "apps-env";
    extraOutputsToInstall = [ "doc" "man" ];
    paths = [
      alacritty
      anki-bin
      bitwarden
      brave
      discord
      feh
      firefox
      libreoffice
      (mpv-with-scripts.override { scripts = [ mpvScripts.mpris ]; })
      nextcloud-client
      quodlibet
      signal-desktop
      spotify
      thunderbird
      unstable.tor-browser-bundle-bin
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
      ((emacsPackagesGen emacs).emacsWithPackages
        (epkgs: [ epkgs.vterm epkgs.pdf-tools ]))
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
    paths = [ crispyDoom dosbox lutris openmw scummvm steam ];
  };

  tools-env = buildEnv {
    name = "tools-env";
    extraOutputsToInstall = [ "doc" "man" ];
    paths = [
      aria2
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
      nixfmt
      pinentry-qt
      protonmail-bridge
      rbw
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
