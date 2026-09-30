{ osConfig, ... }:
{
  programs.zed-editor.enable = osConfig.desktop'.apps.zed.enable;
}
