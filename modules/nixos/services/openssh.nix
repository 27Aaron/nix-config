{
  config,
  lib,
  ...
}: let
  cfg = config.services'.openssh;
in {
  options.services'.openssh = {
    enable = lib.mkEnableOption "OpenSSH daemon";

    port = lib.mkOption {
      type = lib.types.port;
      default = 22;
      description = "TCP port on which OpenSSH listens";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to open the SSH port in the firewall";
    };
  };

  config = lib.mkIf cfg.enable {
    services.openssh = {
      enable = true;
      ports = [cfg.port];

      # Only the Ed25519 host identity is needed; upstream also generates
      # an RSA key by default.
      hostKeys = lib.mkDefault [
        {
          path = "/etc/ssh/ssh_host_ed25519_key";
          type = "ed25519";
        }
      ];

      settings = {
        # root user is used for remote deployment, so we need to allow it
        PermitRootLogin = lib.mkDefault "prohibit-password";
        PasswordAuthentication = lib.mkDefault false;
        # Without this, keyboard-interactive still reaches the PAM password
        # prompt and defeats the key-only intent above.
        KbdInteractiveAuthentication = lib.mkDefault false;
      };
      openFirewall = cfg.openFirewall;
    };

    preservation'.os.directories = ["/etc/ssh"];

    # Client keys and known_hosts; sshd also reads authorized_keys from here.
    preservation'.user.directories = [
      {
        directory = ".ssh";
        mode = "0700";
      }
    ];
  };
}
