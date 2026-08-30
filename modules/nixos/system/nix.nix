{
  lib,
  myvars,
  ...
}: let
  user = myvars.username;
in {
  nix = {
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

  # The configuration checkout read by nh.
  preservation'.user.directories = [
    {
      directory = "nix-config";
      mode = "0700";
    }
  ];
}
