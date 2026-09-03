{
  lib,
  config,
  ...
}: let
  cfg = config.boot'.initrd-ssh;
in {
  options.boot'.initrd-ssh = {
    enable = lib.mkEnableOption "SSH in initrd";

    port = lib.mkOption {
      type = lib.types.port;
      default = 22;
      description = "SSH port for initrd";
    };

    hostKeys = lib.mkOption {
      type = lib.types.listOf (lib.types.either lib.types.str lib.types.path);
      default = ["/etc/secrets/initrd/id_ed25519"];
      description = "Host keys for initrd SSH";
    };
  };

  config = lib.mkIf cfg.enable {
    boot.initrd.network = {
      enable = true;
      ssh = {
        enable = true;
        inherit (cfg) port hostKeys;
      };
    };

    boot.initrd.systemd.users.root.shell = "/bin/systemd-tty-ask-password-agent";

    preservation'.os.directories = ["/etc/secrets/initrd"];
  };
}
