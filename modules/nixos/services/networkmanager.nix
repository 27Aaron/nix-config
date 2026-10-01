{ config, lib, ... }:
let
  cfg = config.services'.networkmanager;
in
{
  options.services'.networkmanager = {
    enable = lib.mkEnableOption "NetworkManager for network configuration";
  };

  config = lib.mkIf cfg.enable {
    networking.networkmanager.enable = true;
    user'.extraGroups = [ "networkmanager" ];

    preservation.preserveAt."/persistent" = lib.mkIf config.hardware'.persistence.enable {
      directories = [
        {
          directory = "/etc/NetworkManager/system-connections";
          mode = "0700";
        }
        "/var/lib/NetworkManager"
      ];
    };
  };
}
