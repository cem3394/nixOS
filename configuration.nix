{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];


  # Supposedly better for the SSD.
  fileSystems."/".options = [ "noatime" "nodiratime" "discard" ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.efiSupport = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Grub menu is painted really slowly on HiDPI, so we lower the
  # resolution. Unfortunately, scaling to 1280x720 (keeping aspect
  # ratio) doesn't seem to work, so we just pick another low one.
  boot.loader.grub.gfxmodeEfi = "1024x768";

  boot.initrd.luks.devices = [
    {
      name = "root";
      device = "/dev/disk/by-uuid/1ef4fb5d-3314-44fe-8319-4d318712e6bf";
      preLVM = true;
      allowDiscards = true;
    }
  ];
  

  networking = {
    hostName = "ovonel";
    networkmanager.enable = true;
  };

  # Select internationalisation properties.
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  # Set time zone.
  time.timeZone = "America/Los_Angeles";

  nixpkgs = {
    config = {
      # Allow proprietary packages
      allowUnfree = true;
      allowBroken = false;
      # Configure Firefox
      firefox = {
       enableGnomeExtensions = true;
       enableGoogleTalkPlugin = true;
      };
      # Create an alias for the unstable channel
      packageOverrides = pkgs: {
        unstable = import <nixos-unstable> {
          # pass the nixpkgs config to the unstable alias
          # to ensure `allowUnfree = true;` is propagated:
          config = config.nixpkgs.config;
        };
      };
    };
    overlays = [(self: super: {
      firefox = super.unstable.firefox;
      neovim = super.neovim.override {
        withPython = true;
        vimAlias = true;
      };
      ninja-kitware = super.callPackage ./rdrpkgs/ninja-kitware {};
      nix-home = super.callPackage ./rdrpkgs/nix-home {};
    })];
  };

  # List packages installed in system profile.
  environment = {
    systemPackages = with pkgs;
    let
      core-packages = [
        acpi
        atool
        bc
        binutils
        busybox
        coreutils
        cryptsetup
        ctags
        curl
        direnv
        exa
        file
        findutils
        gnome3.caribou
        gnome3.gconf
        gnome3.gnome_terminal
        htop
        inotify-tools
        iputils
        neovim
        psmisc
        rsync
        tree
        unrar
        unzip
        wget
        which
        xbindkeys
        xclip
        xsel
        zip 
      ];
      crypt-packages = [
        git-crypt
        gnupg1
        kbfs
        keybase
        keybase-gui
      ];
      development-packages = [
        autoconf
        automake
        clang-tools    
        htop
        tmux
        tree
        colordiff
        silver-searcher
        vim_configurable
        gitAndTools.gitFull
        python
        kde4.kdiff3
        vimPlugins.YouCompleteMe
        vimPlugins.gitgutter

        # Haskell development in vim
        vimPlugins.vimproc-vim
        vimPlugins.vim-hdevtools
        vimPlugins.ghc-mod-vim

        # needed for vim-hdevtools
        haskellPackages.ghc
        /*haskellPackages.ghc-mod*/
        haskellPackages.cabal-install
        haskellPackages.cabal2nix
        haskellPackages.hdevtools
        haskellPackages.yesod-bin

        # needed for compiling vimproc's shared library
        gnutar
        gnumake
        gzip
        gcc
        binutils
        coreutils
        gawk
        gnused
        gnugrep 
      ];
      nix-packages = [
        nix-home
        nix-prefetch-git
        nix-repl
        nixos-container
        nixpkgs-lint
        nox
        patchelf
      ];
      user-packages = [
        areca
        aspell
        aspellDicts.en
        aspellDicts.it
        aspellDicts.nb
        calibre
        chrome-gnome-shell
        chromium
        drive
        evince
        feh
        firefox
        ghostscript
        imagemagick
        libreoffice
        liferea
        meld
        pass
        pdftk
        rambox
        shutter
        spotify
        taskwarrior
        transmission
        transmission_gtk
        vlc
      ];
    in
      core-packages
      ++ crypt-packages
      ++ development-packages
      ++ nix-packages
      ++ user-packages;

    gnome3.excludePackages = with pkgs.gnome3; [ epiphany evolution totem vino yelp accerciser ];
    variables.EDITOR = "nvim";
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs = {
    fish.enable = true;
    thefuck.enable = true;
    tmux.enable = true;
  };

  virtualisation.docker = {
    enable = true;
    enableOnBoot = false;
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "17.09";
}
