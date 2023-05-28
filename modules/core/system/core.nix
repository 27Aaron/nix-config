{
  lib,
  config,
  inputs,
  ...
}: let
  cfg = config.core';
in {
  imports = [
    inputs.home-manager.nixosModules.home-manager
    (lib.mkAliasOptionModule ["user'"] ["users" "users" cfg.userName])
    (lib.mkAliasOptionModule ["hm'"] ["home-manager" "users" cfg.userName])
  ];

  options.core' = {
    hostName = lib.mkOption {
      type = lib.types.str;
      description = "Network hostname";
    };
    sshKeys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKHjMAQUXfyMv8TG1NfqjmQJG3gqZkh25KAvAMvxVrWS Aaron@MacBook-Pro"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA6xNNhF6jaPKuch8vSHwHTGlbyn4i2zSHxrqGOiacxG Aaron@Deployment"
      ];
      example = ["ssh-ed25519 AAAA..."];
      description = "SSH public keys for the main user";
    };
    stateVersion = lib.mkOption {
      type = lib.types.str;
      default = "26.05";
      description = "NixOS state version";
    };
    timeZone = lib.mkOption {
      type = lib.types.str;
      default = "Asia/Singapore";
      description = "System timezone";
    };
    userName = lib.mkOption {
      type = lib.types.str;
      description = "Login user name";
    };
  };

  config = {
    users.mutableUsers = false;
    users.users = {
      root = {
        hashedPassword = "$y$j9T$wKu2x.HrtXWLzO6Jot0y61$MHSAMfxnEacwmiQSzhhtBsm5iKcDfFDtBFA/gnWrGY3";
        openssh.authorizedKeys.keys = cfg.sshKeys;
      };
      ${cfg.userName} = {
        isNormalUser = true;
        extraGroups = ["wheel"];
        hashedPassword = "$y$j9T$wKu2x.HrtXWLzO6Jot0y61$MHSAMfxnEacwmiQSzhhtBsm5iKcDfFDtBFA/gnWrGY3";
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
