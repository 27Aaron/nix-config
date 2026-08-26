{
  config,
  lib,
  ...
}: let
  cfg = config.services'.networkmanager;
in {
  options.services'.networkmanager = {
    enable = lib.mkEnableOption "NetworkManager for network configuration";
  };

  config = lib.mkIf cfg.enable {
    networking.networkmanager.enable = true;

    user'.extraGroups = ["networkmanager"];
  };
}
