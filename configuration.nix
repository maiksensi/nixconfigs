# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let zsh = "/run/current-system/sw/bin/zsh";
    home = "/home/maiksen";

    user = { # don't forget to set a password with passwd
      name = "maiksen";
      group = "users";
      extraGroups = ["networkmanager" "wheel"];
      uid = 1000;
      createHome = true;
      home = home;
      shell = zsh;
      openssh.authorizedKeys.keys = ["ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDADRTn85x2+6kWlfX0s8fbPZSyKBlBRQS+szVIp8QruiOgeOfoULFjfexKbQHa9IPKAJ4Vj2MhJWQNW4qRvltEHUk6koSgjgZ6DSuUEDq3Rc5pJeDCP2k7ib2qyE0X6aDtlGHGOK1MgiALpc6aTrtxR6uE6rI8GG/cJTzk08QjExynguVWYwxyjdMegCXo+82S9ZqKVoEBIy51m5W4Vsh5jKgiM+27EnRWy6BbsvDJiEgtLBknA9X2OxDKFl75Qmo/hSZ+RypAcU4a9pBKYcF4/jOQQ+Sbn9RzFVFP66tVODdH5eZG7xnH7mpg0fHvdiuEdXfb/IZ0KK2t3WF7rnQ7 maiksen@faulbook"];
    };
    antigen = pkgs.fetchgit {
      url = "https://github.com/zsh-users/antigen";
      rev = "1d212d149d039cc8d7fdf90c016be6596b0d2f6b";
      sha256 = "1c7ipgs8gvxng3638bipcj8c1s1dn3bb97j8c73piv2xgk42aqb9";
    };

in {
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only

  networking.hostName = "samba"; # Define your hostname.

  # Select internationalisation properties.
  i18n = {
    #consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget

  users.extraUsers.maiksen = user;
  users.extraGroups.sudo.members = ["maiksen"];
  environment.systemPackages = with pkgs; [
     wget
     curl
     emacs
     git # antigen needs it
     homesick 
   ];

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    permitRootLogin = "no";
    passwordAuthentication = false;
  };

   #services.openssh.enable = true;
   #services.openssh.permitRootLogin = "no";

  # enable samba server
  services.samba.enable = true;


  programs.zsh = {
    enable = true;
    shellAliases = {
      g = "git";
    };
    enableCompletion = true;
    interactiveShellInit = ''
      source ${antigen}/antigen.zsh
      # Load the oh-my-zsh's library.
      antigen use oh-my-zsh
      # Bundles from the default repo (robbyrussell's oh-my-zsh).
      antigen bundle git
      antigen bundle git-extras
      antigen bundle cabal
      antigen bundle sbt
      antigen bundle scala
      # Syntax highlighting bundle.
      antigen bundle zsh-users/zsh-syntax-highlighting
      # Load the theme.
      antigen theme bira
      # Tell antigen that you're done.
      antigen apply     
    '';
  };

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "17.03";

}
