{
  lib,
  pkgs,
  username,
  ...
}:
let
  niriSession = lib.getExe' pkgs.niri "niri-session";
in
{
  programs.niri.enable = true;

  environment.systemPackages = [ pkgs.xwayland-satellite ];

  services.greetd = {
    enable = true;
    settings.default_session.command = "${lib.getExe pkgs.tuigreet} --time --cmd ${niriSession}";
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
  };

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      waylandFrontend = true;
      addons = with pkgs; [
        fcitx5-gtk
        fcitx5-rime
      ];
    };
  };

  fonts.packages = with pkgs; [
    lxgw-wenkai
    maple-mono.NF-CN-unhinted
    nerd-fonts.jetbrains-mono
    noto-fonts-color-emoji
    source-han-sans
    source-han-serif
  ];

  home-manager.users.${username} = {
    programs.firefox.enable = true;
    programs.vscode.enable = true;
    programs.zed-editor.enable = true;
  };
}
