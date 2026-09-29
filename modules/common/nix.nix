{
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
    };
  };

  nixpkgs.config.allowUnfree = true;
}
