{
  lib,
  myvars,
  ...
}:
let
  user = myvars.username;
in
{
  nix = {
    gc.dates = lib.mkDefault "weekly";
    settings = {
      trusted-users = [ user ];
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
