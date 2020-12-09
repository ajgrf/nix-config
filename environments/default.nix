{ stable, unstable, ... }:

with stable.pkgs; rec {

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
      anki
      bitwarden
      ungoogled-chromium
      feh
      firefox
      gnome3.gnome-boxes
      gnome3.gnome-tweaks
      libreoffice
      lollypop
      pinentry-gtk2
      # quodlibet
      unstable.pkgs.signal-desktop
      spotify
      thunderbird
      tor-browser-bundle-bin
      transmission-gtk
      virt-manager
      vlc
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
      ((emacsPackagesGen emacs).emacsWithPackages (epkgs: [
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
      unstable.pkgs.kopia
      ledger
      libnotify
      moreutils
      pass
      unstable.protonmail-bridge
      rclone
      reptyr
      rsync
      shellcheck
      shfmt
      stow
      tmux
      trash-cli
      youtube-dl
    ];
  };
}
