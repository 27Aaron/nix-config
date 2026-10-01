{
  config,
  lib,
  ...
}:
let
  cfg = config.hardware'.initrd-ssh;
in
{
  options.hardware'.initrd-ssh = {
    enable = lib.mkEnableOption "SSH in initrd for remote LUKS unlock";

    port = lib.mkOption {
      type = lib.types.port;
      default = 22;
      description = "SSH port used by the initrd service.";
    };

    hostKeys = lib.mkOption {
      type = lib.types.listOf (lib.types.either lib.types.str lib.types.path);
      default = [ "/etc/secrets/initrd/id_ed25519" ];
      description = "Host keys used by the initrd SSH service.";
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

    preservation.preserveAt."/persistent".directories = lib.mkIf config.hardware'.persistence.enable [
      "/etc/secrets/initrd"
    ];
  };
}
