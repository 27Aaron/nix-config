{
  config,
  lib,
  ...
}: let
  cfg = config.services'.openssh;
in {
  options.services'.openssh = {
    enable = lib.mkEnableOption "OpenSSH daemon";
  };

  config = lib.mkIf cfg.enable {
    services.openssh = {
      enable = lib.mkDefault true;
      ports = lib.mkDefault [233];
      settings = {
        # root user is used for remote deployment, so we need to allow it
        PermitRootLogin = lib.mkDefault "prohibit-password";
        PasswordAuthentication = lib.mkDefault false;
      };
      openFirewall = lib.mkDefault true;
    };

    # Add terminfo database of all known terminals to the system profile.
    # https://github.com/NixOS/nixpkgs/blob/nixos-25.05/nixos/modules/config/terminfo.nix
    environment.enableAllTerminfo = lib.mkDefault true;
  };
}
