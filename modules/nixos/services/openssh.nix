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
      default = 233;
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
      settings = {
        # root user is used for remote deployment, so we need to allow it
        PermitRootLogin = lib.mkDefault "prohibit-password";
        PasswordAuthentication = lib.mkDefault false;
      };
      openFirewall = cfg.openFirewall;
    };
  };
}
