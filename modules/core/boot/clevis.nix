{
  lib,
  config,
  inputs,
  ...
}: let
  cfg = config.boot'.clevis;
in {
  options.boot'.clevis = {
    enable = lib.mkEnableOption "Clevis LUKS auto-unlock with Tang";
  };

  config = lib.mkIf cfg.enable {
    boot.initrd = {
      network.enable = true;
      clevis = {
        enable = true;
        useTang = true;
        devices."crypted".secretFile = "${inputs.my-secrets}/services/clevis_key.jwe";
      };
    };
  };
}
