{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.desktop'.fonts;
in
{
  options.desktop'.fonts = {
    enable = lib.mkEnableOption "desktop fonts";
  };

  config = lib.mkIf cfg.enable {
    fonts.packages = with pkgs; [
      lxgw-wenkai
      maple-mono.NF-CN-unhinted
      nerd-fonts.jetbrains-mono
      noto-fonts-color-emoji
      source-han-sans
      source-han-serif
    ];
  };
}
