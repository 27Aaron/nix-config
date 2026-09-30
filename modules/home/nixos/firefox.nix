{ osConfig, ... }:
{
  programs.firefox.enable = osConfig.desktop'.apps.firefox.enable;
}
