{
  lib,
  config,
  inputs,
  ...
}:
let
  cfg = config.core';
in
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    (lib.mkAliasOptionModule [ "user'" ] [ "users" "users" cfg.userName ])
    (lib.mkAliasOptionModule [ "hm'" ] [ "home-manager" "users" cfg.userName ])
  ];

  options.core' = {
    userName = lib.mkOption {
      type = lib.types.str;
      description = "Login user name";
    };
    hostName = lib.mkOption {
      type = lib.types.str;
      description = "Network hostname";
    };
    timeZone = lib.mkOption {
      type = lib.types.str;
      default = "Asia/Singapore";
      description = "System timezone";
    };
    stateVersion = lib.mkOption {
      type = lib.types.str;
      default = "26.05";
      description = "NixOS state version";
    };
    sshKeys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA6xNNhF6jaPKuch8vSHwHTGlbyn4i2zSHxrqGOiacxG Aaron@Deployment"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKHjMAQUXfyMv8TG1NfqjmQJG3gqZkh25KAvAMvxVrWS Aaron@MacBook-Pro"
      ];
      example = [ "ssh-ed25519 AAAA..." ];
      description = "SSH public keys for the main user";
    };
  };

  config = {
    users.mutableUsers = false;
    users.users = {
      root = {
        hashedPassword = "$y$j9T$9BVbJKhiRZ/U5iTL7sZtT/$3xUVDretSE/RqiacfJbu/vK0Li0H8Z/S4LESEj1E/u1";
        openssh.authorizedKeys.keys = cfg.sshKeys;
      };
      ${cfg.userName} = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        hashedPassword = "$y$j9T$9BVbJKhiRZ/U5iTL7sZtT/$3xUVDretSE/RqiacfJbu/vK0Li0H8Z/S4LESEj1E/u1";
        openssh.authorizedKeys.keys = cfg.sshKeys;
      };
    };

    networking.hostName = cfg.hostName;
    time.timeZone = cfg.timeZone;
    system.stateVersion = cfg.stateVersion;

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "hm-bak";
    };

    home-manager.users.${cfg.userName} = {
      home.stateVersion = cfg.stateVersion;
      xdg.enable = true;
    };
  };
}
