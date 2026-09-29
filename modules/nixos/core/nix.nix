{
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
    flake = lib.mkDefault myvars.path.nixConfig;
  };

  # The configuration checkout read by nh.
  preservation'.user.directories = [
    {
      directory = myvars.path.nixConfigDir;
      mode = "0700";
    }
  ];
}
