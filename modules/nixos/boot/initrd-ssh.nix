{
  lib,
  config,
  ...
}: let
  cfg = config.boot'.initrd-ssh;
in {
  options.boot'.initrd-ssh = {
    enable = lib.mkEnableOption ''
      SSH in initrd for remote LUKS unlock. The host must ensure its NIC
      driver (e.g. r8169, igc, virtio_net) is present in
      boot.initrd.availableKernelModules, or the initrd will have no network.
    '';

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

        # Show the LUKS passphrase prompt inside the SSH session instead of
        # a plain shell.
        shell = "/bin/systemd-tty-ask-password-agent";
      };
    };

    preservation'.os.directories = ["/etc/secrets/initrd"];
  };
}
