{
  helpers,
  lib,
  myvars,
  ...
}:
{
  nix = {
    settings = {
      trusted-users = [ myvars.username ];
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
