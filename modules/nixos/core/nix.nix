{
  lib,
  myvars,
  ...
}:
{
  nix = {
    enable = true;

    # remove nix-channel related tools & configs, we use flakes instead.
    channel.enable = false;

    gc = {
      automatic = true;
      options = "--delete-older-than 7d";
      dates = "weekly";
    };

    optimise.automatic = true;

    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];

      extra-substituters = myvars.nix.substituters;
      extra-trusted-public-keys = myvars.nix.trustedPublicKeys;
      trusted-users = [ myvars.username ];
    };
  };

  nixpkgs.config.allowUnfree = true;

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
