{
  hostName,
  myvars,
  ...
}: let
  userName = myvars.username;
  hashedPassword = myvars.hashedPassword;
  sshKeys = myvars.sshAuthorizedKeys;
in {
  users.mutableUsers = false;

  users.users = {
    root = {
      inherit hashedPassword;
      openssh.authorizedKeys.keys = sshKeys;
    };

    ${userName} = {
      isNormalUser = true;
      extraGroups = ["wheel"];
      inherit hashedPassword;
      openssh.authorizedKeys.keys = sshKeys;
    };
  };

  networking.hostName = hostName;
  time.timeZone = myvars.timeZone;
  system.stateVersion = myvars.stateVersion;

  documentation = {
    man.cache.enable = false;
    nixos.enable = false;
  };
}
