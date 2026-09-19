{
  helpers,
  lib,
  myvars,
  ...
}:
let
  user = myvars.username;
in
{
  nix = {
    settings = {
      trusted-users = [ user ];
    };
  };

  programs.nh = {
    enable = true;
    flake = lib.mkDefault helpers.path.nixConfig;
  };

  # The configuration checkout read by nh.
  preservation'.user.directories = [
    {
      directory = helpers.path.nixConfigDir;
      mode = "0700";
    }
  ];
}
