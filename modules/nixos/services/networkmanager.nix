{
  config,
  lib,
  myvars,
  ...
}: let
  cfg = config.services'.networkmanager;
  user = myvars.username;
in {
  options.services'.networkmanager = {
    enable = lib.mkEnableOption "NetworkManager for network configuration";
  };

  config = lib.mkIf cfg.enable {
    networking.networkmanager.enable = lib.mkDefault true;

    users.users.${user}.extraGroups = ["networkmanager"];
  };
}
