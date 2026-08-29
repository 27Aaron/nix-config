{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.tools'.dev;
in {
  options.tools'.dev.enable = lib.mkEnableOption "development CLI toolset for interactive hosts";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      alejandra
      deadnix
      nixd
    ];

    hm'.programs.direnv = {
      enable = true;
      nix-direnv = {
        enable = true;
        package = pkgs.nix-direnv;
      };
    };

    hm'.home.packages = with pkgs; [
      gh
      lazygit
      uv
    ];

    # GitHub CLI account settings and fallback credentials.
    hm'.persist'.directories = [
      {
        directory = ".config/gh";
        mode = "0700";
      }
    ];
  };
}
