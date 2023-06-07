{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
with lib; let
  cfg = config.services'.snell-server;
in {
  options.services'.snell-server = {
    enable = mkEnableOption "Enable Snell Server";

    package = mkOption {
      type = types.package;
      default = inputs.nur-aaron.packages.${pkgs.stdenv.hostPlatform.system}.snell-server;
    };

    port = mkOption {
      type = types.int;
      default = 23333;
      description = "The port Snell Server listens on.";
    };

    ipv6 = mkOption {
      type = types.bool;
      default = true;
      description = "Enable or disable IPv6 support.";
    };

    obfs = mkOption {
      type = types.enum [
        "off"
        "tls"
        "http"
      ];
      default = "off";
      description = "The obfuscation method to use.";
    };

    dns = mkOption {
      type = types.str;
      default = "1.1.1.1, 1.0.0.1, 2606:4700:4700::1111, 2606:4700:4700::1001";
      description = "DNS servers for Snell Server.";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [cfg.package];

    sops.secrets.snell_psk = {
      sopsFile = "${inputs.my-secrets}/services/snell.yaml";
    };

    systemd.services.snell-server = {
      after = [
        "network.target"
        "sops-nix.service"
      ];
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        Type = "simple";
        Restart = "always";
        RestartSec = "3";
        RuntimeDirectory = "snell";
        ExecStart = pkgs.writeShellScript "snell-server" ''
          cfg="/run/snell/snell.conf"
          psk=$(cat ${config.sops.secrets.snell_psk.path})
          echo "[snell-server]" > "$cfg"
          echo "listen = ${
            if cfg.ipv6
            then "[::0]"
            else "0.0.0.0"
          }:${toString cfg.port}" >> "$cfg"
          echo "ipv6 = ${boolToString cfg.ipv6}" >> "$cfg"
          echo "psk = $psk" >> "$cfg"
          echo "obfs = ${cfg.obfs}" >> "$cfg"
          echo "dns = ${cfg.dns}" >> "$cfg"
          exec ${cfg.package}/bin/snell-server -c "$cfg"
        '';
        PrivateTmp = true;
        NoNewPrivileges = true;
      };
    };

    networking.firewall = {
      allowedTCPPorts = [cfg.port];
      allowedUDPPorts = [cfg.port];
    };
  };
}
