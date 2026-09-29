# Basic system setup: hostname, user accounts and SSH.
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

  services.openssh = {
    enable = true;
    ports = [ myvars.port.openssh ];

    # Only the Ed25519 host identity is needed.
    hostKeys = [
      {
        path = "/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];

    settings = {
      # The root user is used for remote deployment.
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      X11Forwarding = false;
    };
  };
}
