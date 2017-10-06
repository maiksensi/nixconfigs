# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let zsh = "/run/current-system/sw/bin/zsh";
    home = "/home/maiksen";
    maiksen = { # don't forget to set a password with passwd
      name = "maiksen";
      group = "maiksen";
      extraGroups = ["networkmanager" "wheel" "smbgrp"];
      uid = 1000;
      createHome = true;
      home = home;
      shell = zsh;
      openssh.authorizedKeys.keys = ["ssh-rsa 
AAAAB3NzaC1yc2EAAAADAQABAAABAQDADRTn85x2+6kWlfX0s8fbPZSyKBlBRQS+szVIp8QruiOgeOfoULFjfexKbQHa9IPKAJ4Vj2MhJWQNW4qRvltEHUk6koSgjgZ6DSuUEDq3Rc5pJeDCP2k7ib2qyE0X6aDtlGHGOK1MgiALpc6aTrtxR6uE6rI8GG/cJTzk08QjExynguVWYwxyjdMegCXo+82S9ZqKVoEBIy51m5W4Vsh5jKgiM+27EnRWy6BbsvDJiEgtLBknA9X2OxDKFl75Qmo/hSZ+RypAcU4a9pBKYcF4/jOQQ+Sbn9RzFVFP66tVODdH5eZG7xnH7mpg0fHvdiuEdXfb/IZ0KK2t3WF7rnQ7 
maiksen@faulbook"];
    };
    antigen = pkgs.fetchgit {
      url = "https://github.com/zsh-users/antigen";
      rev = "1d212d149d039cc8d7fdf90c016be6596b0d2f6b";
      sha256 = "1c7ipgs8gvxng3638bipcj8c1s1dn3bb97j8c73piv2xgk42aqb9";
    };

    anna = {
      name = "anna";
      group = "anna";
      extraGroups = ["smbgrp"];
      createHome = false;
      shell = pkgs.nologin; 
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

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "17.03";

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

  users.extraUsers.maiksen = maiksen;
  users.extraUsers.anna = anna;
  users.groups = {anna = {}; maiksen = {}; smbgrp = {};};
  users.extraGroups.sudo.members = ["maiksen"];
  environment.systemPackages = with pkgs; [
     wget
     curl
     emacs
     git # antigen needs it
     homesick # manage homefiles
     samba
   ];

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    ports = [41678];
    permitRootLogin = "no";
    passwordAuthentication = false;
  };



  # enable samba server
  # create both users afterwards with
  # smbpasswd -a maiksen
  # smbpasswd -a anna
  services.samba = {
    enable = true;
    invalidUsers = ["root"];
    extraConfig = ''
      security = user
      invalid users  = ["root"]
      workgroup = WORKGROUP
      netbios name = samba
      interfaces = enp0s18
      log file = /var/log/samba/myshares
      log level = 1
      map to guest = Bad User
      dns proxy = no
      server string = SambaServer

      [data]
      path = /srv/data/
      public = yes
      guest ok = no
      writeable = yes
      valid users = @smbgrp
      create mask = 0770
      directory mask = 0770
      force group = smbgrp
      browsable = yes
      comment = "Your data share"

      [maik]
      path = /srv/maik/
      valid users = maiksen
      read only = no
      browseable = yes
      guest ok = no
      create mask = 0770
      directory mask = 0770
      force user = maiksen
      force group = maiksen
      comment = "My data share"

      [anna]
      path = /srv/anna/
      valid users = anna
      read only = no
      browseable = yes
      guest ok = no
      create mask = 0770
      directory mask = 0770
      force user = anna
      force group = anna
      comment = "My data share"
      '';
  };

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

networking.firewall.enable = true;
networking.firewall.allowPing = true;
networking.firewall.allowedTCPPorts = [ 445 139 41678 22];
networking.firewall.allowedUDPPorts = [ 137 138 ];

}
