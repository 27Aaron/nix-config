{
  lib,
  myvars,
  pkgs,
  ...
}: {
  nix = {
    package = pkgs.nix;
    gc.dates = lib.mkDefault "weekly";
    settings = {
      substituters = lib.mkAfter ["https://attic.xuyh0120.win/lantian"];
      trusted-public-keys = lib.mkAfter ["lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="];
      trusted-users = [myvars.username];
    };
  };

  programs.nh = {
    enable = true;
    flake = "/home/${myvars.username}/nix-config";
  };
}
