{
  lib,
  config,
  ...
}:
let
  cfg = config.services'.networkmanager;
  user = config.core'.userName;
in
{
  options.services'.networkmanager = {
    enable = lib.mkEnableOption "NetworkManager for network configuration";
  };

  config = lib.mkIf cfg.enable {
    networking.networkmanager.enable = true;

    users.users.${user}.extraGroups = [ "networkmanager" ];

    preservation'.os.directories = [
      "/etc/NetworkManager/system-connections"
      "/var/lib/NetworkManager"
    ];
  };
}
