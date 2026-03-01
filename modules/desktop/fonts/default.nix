{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.desktop'.fonts;
in
{
  options.desktop'.fonts = {
    enable = lib.mkEnableOption "System fonts configuration";
  };

  config = lib.mkIf cfg.enable {
    fonts = {
      enableDefaultPackages = false;
      fontDir.enable = true;

      packages = with pkgs; [
        material-design-icons
        font-awesome
        noto-fonts-color-emoji
        nerd-fonts.fira-code
        nerd-fonts.symbols-only
        nerd-fonts.jetbrains-mono
        maple-mono.NF-CN-unhinted
        source-sans
        source-serif
        source-han-sans
        source-han-serif
        lxgw-wenkai
        julia-mono
        dejavu_fonts
      ];

      fontconfig.defaultFonts = {
        serif = [
          "Source Han Serif SC"
          "Source Han Serif TC"
        ];
        sansSerif = [
          "Source Han Sans SC"
          "Source Han Sans TC"
        ];
        monospace = [
          "Maple Mono NF CN"
        ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };
}
