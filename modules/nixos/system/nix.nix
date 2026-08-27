{
  lib,
  myvars,
  pkgs,
  ...
}: let
  user = myvars.username;
in {
  nix = {
    package = pkgs.nix;
    gc.dates = lib.mkDefault "weekly";
    settings = {
      substituters = lib.mkAfter ["https://attic.xuyh0120.win/lantian"];
      trusted-public-keys = lib.mkAfter ["lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="];
      trusted-users = [user];
    };
  };

  programs.nh = {
    enable = true;
    flake = lib.mkDefault "/home/${user}/nix-config";
  };
}
