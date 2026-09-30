{ lib, ... }:
{
  options.desktop'.mime-apps = {
    enable = lib.mkEnableOption "XDG MIME application associations";
  };
}
