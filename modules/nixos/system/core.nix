{
  config,
  lib,
  hostName,
  myvars,
  ...
}: let
  cfg = config.core';
in {
  imports = [
    (lib.mkAliasOptionModule ["user'"] ["users" "users" myvars.username])
    (lib.mkAliasOptionModule ["hm'"] ["home-manager" "users" myvars.username])
  ];

  options.core' = {
    hostName = lib.mkOption {
      type = lib.types.str;
      default = hostName;
      description = "NixOS host name";
    };

    timeZone = lib.mkOption {
      type = lib.types.str;
      default = myvars.timeZone;
      description = "System time zone";
    };

    hashedPassword = lib.mkOption {
      type = lib.types.str;
      default = myvars.hashedPassword;
      description = "Hashed password shared by the primary user and root";
    };

    sshAuthorizedKeys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = myvars.sshAuthorizedKeys;
      description = "SSH keys authorized for the primary user and root";
    };
  };

  config = {
    users.mutableUsers = false;

    users.users = {
      root = {
        hashedPassword = cfg.hashedPassword;
        openssh.authorizedKeys.keys = cfg.sshAuthorizedKeys;
      };

      ${myvars.username} = {
        isNormalUser = true;
        extraGroups = ["wheel"];
        hashedPassword = cfg.hashedPassword;
        openssh.authorizedKeys.keys = cfg.sshAuthorizedKeys;
      };
    };

    networking.hostName = cfg.hostName;
    time.timeZone = lib.mkDefault cfg.timeZone;

    # Add the terminfo database of all known terminals to the system profile.
    environment.enableAllTerminfo = lib.mkDefault true;

    documentation = {
      man.cache.enable = false;
      nixos.enable = false;
    };
  };
}
