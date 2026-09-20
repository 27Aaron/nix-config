{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.development'.dev;
in
{
  options.development'.dev = {
    enable = lib.mkEnableOption "development CLI toolset for interactive hosts";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      deadnix
      nixd
      nixfmt-rs
    ];

    hm'.programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    hm'.home.packages = with pkgs; [
      uv
    ];

    # Runtime state of the toolset above: direnv .envrc allow-list and
    # uv-managed interpreters and tools.
    hm'.persist'.directories = [
      ".local/share/direnv"
      ".local/share/uv"
    ];
  };
}
