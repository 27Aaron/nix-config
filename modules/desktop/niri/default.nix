{
  lib,
  pkgs,
  config,
  ...
}:
let
  mkSymlink = config.lib.file.mkOutOfStoreSymlink;
  confPath = "/etc/nixos/nix-config/modules/desktop/niri/conf";
in
{
  options.desktop'.niri = {
    enable = lib.mkEnableOption "niri Wayland compositor";
  };

  config = lib.mkIf config.desktop'.niri.enable {
    programs.niri.enable = true;

    hm'.home.packages = with pkgs; [
      fuzzel
      polkit_gnome
      xwayland-satellite
    ];

    hm'.xdg.configFile = {
      "niri/config.kdl".source = mkSymlink "${confPath}/config.kdl";
      "niri/keybindings.kdl".source = mkSymlink "${confPath}/keybindings.kdl";
      "niri/noctalia-shell.kdl".source = mkSymlink "${confPath}/noctalia-shell.kdl";
      "niri/spawn-at-startup.kdl".source = mkSymlink "${confPath}/spawn-at-startup.kdl";
      "niri/windowrules.kdl".source = mkSymlink "${confPath}/windowrules.kdl";
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
