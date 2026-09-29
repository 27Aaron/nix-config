{
  config,
  lib,
  myvars,
  ...
}:
let
  cfg = config.services'.openssh;
in
{
  options.services'.openssh = {
    enable = lib.mkEnableOption "OpenSSH daemon";
  };

  config = lib.mkIf cfg.enable {
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

    preservation'.os.directories = [ "/etc/ssh" ];

    # Client keys and known_hosts; sshd also reads authorized_keys from here.
    preservation'.user.directories = [
      {
        directory = ".ssh";
        mode = "0700";
      }
    ];
  };
}
