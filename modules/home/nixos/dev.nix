{
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  enable = osConfig.development'.dev.enable;
in
{
  programs.direnv = lib.mkIf enable {
    enable = true;
    nix-direnv.enable = true;
  };

  home.packages = lib.mkIf enable [ pkgs.uv ];
}
