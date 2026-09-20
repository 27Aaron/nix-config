{
  helpers,
  lib,
  hostName,
  myvars,
  pkgs,
  ...
}:
{
  config = {
    programs.fish.enable = lib.mkDefault true;

    time.timeZone = lib.mkDefault myvars.timeZone;

    system = {
      primaryUser = myvars.username;
    };

    users.users.${myvars.username} = {
      home = helpers.path.homeDirectory;

      # fish must be registered in /etc/shells before it can be the
      # login shell; programs.fish.enable above takes care of that.
      shell = lib.mkDefault pkgs.fish;
    };

    networking = {
      hostName = hostName;
      computerName = hostName;
    };
    system.defaults.smb.NetBIOSName = hostName;
  };
}
