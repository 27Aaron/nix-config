# Basic system setup: hostname and user accounts.
{ myvars, ... }:
{
  networking.hostName = "router";

  time.timeZone = myvars.timeZone;

  users.mutableUsers = false;

  users.users.root = {
    hashedPassword = myvars.hashedPassword;
    openssh.authorizedKeys.keys = myvars.sshAuthorizedKeys;
  };

  users.users.${myvars.username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    hashedPassword = myvars.hashedPassword;
    openssh.authorizedKeys.keys = myvars.sshAuthorizedKeys;
  };

  # Add the terminfo database of all known terminals to the system profile.
  environment.enableAllTerminfo = true;

  documentation = {
    man.cache.enable = false;
    nixos.enable = false;
  };
}
