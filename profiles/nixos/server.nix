{ lib, ... }:
{
  imports = [ ./default.nix ];

  core'.firewall.enable = true;

  # Hosts supply their own SSH keys and network configuration.
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = lib.mkDefault false;
      KbdInteractiveAuthentication = lib.mkDefault false;
      PermitRootLogin = lib.mkDefault "prohibit-password";
    };
  };
}
