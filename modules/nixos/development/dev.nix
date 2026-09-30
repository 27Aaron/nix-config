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
      nil
      nixd
      nixfmt-rs
      prettier
    ];

    # Runtime state of the HM-side toolset: the direnv .envrc allow-list
    # and uv-managed interpreters and tools.
    preservation'.user.directories = [
      ".local/share/direnv"
      ".local/share/uv"
    ];
  };
}
