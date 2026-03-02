{
  lib,
  pkgs,
  config,
  ...
}:
let
  mkSymlink = config.home-manager.users.${config.core'.userName}.lib.file.mkOutOfStoreSymlink;
  confPath = "/etc/nixos/nix-config/modules/desktop/niri/conf";
in
{
  options.desktop'.niri = {
    enable = lib.mkEnableOption "Niri Wayland compositor";
  };

  config = lib.mkIf config.desktop'.niri.enable {
    programs.niri.enable = true;

    environment.systemPackages = with pkgs; [
      inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];

    hm'.home.packages = with pkgs; [
      kitty
      fuzzel
      polkit_gnome
      xwayland-satellite
    ];

    hm'.xdg.configFile = {
      "niri/animations.kdl".source = mkSymlink "${confPath}/animations.kdl";
      "niri/binds.kdl".source = mkSymlink "${confPath}/binds.kdl";
      "niri/config.kdl".source = mkSymlink "${confPath}/config.kdl";
      "niri/input.kdl".source = mkSymlink "${confPath}/input.kdl";
      "niri/layout.kdl".source = mkSymlink "${confPath}/layout.kdl";
      "niri/noctalia-shell.kdl".source = mkSymlink "${confPath}/noctalia-shell.kdl";
      "niri/output.kdl".source = mkSymlink "${confPath}/output.kdl";
      "niri/spawn-at-startup.kdl".source = mkSymlink "${confPath}/spawn-at-startup.kdl";
      "niri/window-rule.kdl".source = mkSymlink "${confPath}/window-rule.kdl";
    };

    hm'.systemd.user.services.polkit-gnome-authentication-agent = {
      Unit = {
        Description = "GNOME Polkit Authentication Agent";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
      };
      Install = {
        WantedBy = [ "niri.service" ];
      };
    };

    # NOTE: this executable is used by greetd to start a wayland session when system boot up
    # with such a vendor-no-locking script, we can switch to another wayland compositor without modifying greetd's config in NixOS module
    hm'.home.file.".wayland-session" = {
      source = pkgs.writeScript "init-session" ''
        systemctl --user is-active niri.service && systemctl --user stop niri.service
        /run/current-system/sw/bin/niri-session
      '';
      executable = true;
    };
  };
}
