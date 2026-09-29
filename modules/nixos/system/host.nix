{
  lib,
  hostName,
  myvars,
  ...
}:
{
  config = {
    users.mutableUsers = false;

    users.users = {
      root = {
        hashedPassword = myvars.hashedPassword;
        openssh.authorizedKeys.keys = myvars.sshAuthorizedKeys;
      };

      ${myvars.username} = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        hashedPassword = myvars.hashedPassword;
        openssh.authorizedKeys.keys = myvars.sshAuthorizedKeys;
      };
    };

    networking.hostName = hostName;
    time.timeZone = lib.mkDefault myvars.timeZone;

    # Add the terminfo database of all known terminals to the system profile.
    environment.enableAllTerminfo = lib.mkDefault true;

    documentation = {
      man.cache.enable = false;
      nixos.enable = false;
    };
  };
}
