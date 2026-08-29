{
  config,
  lib,
  hostName,
  myvars,
  pkgs,
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
      description = "macOS host name";
    };

    timeZone = lib.mkOption {
      type = lib.types.str;
      default = myvars.timeZone;
      description = "System time zone";
    };
  };

  config = {
    programs.fish.enable = lib.mkDefault true;

    time.timeZone = lib.mkDefault cfg.timeZone;

    system = {
      primaryUser = myvars.username;
    };

    users.users.${myvars.username} = {
      home = "/Users/${myvars.username}";

      # fish must be registered in /etc/shells before it can be the
      # login shell; programs.fish.enable above takes care of that.
      shell = lib.mkDefault pkgs.fish;
    };

    networking = {
      hostName = cfg.hostName;
      computerName = cfg.hostName;
    };
    system.defaults.smb.NetBIOSName = cfg.hostName;
  };
}
