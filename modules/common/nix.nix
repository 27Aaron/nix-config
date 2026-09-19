{
  helpers,
  lib,
  ...
}:
{
  nix = {
    # remove nix-channel related tools & configs, we use flakes instead.
    channel.enable = false;

    gc = {
      automatic = lib.mkDefault true;
      options = lib.mkDefault "--delete-older-than 7d";
    };

    optimise.automatic = true;

    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];

      extra-substituters = helpers.nix.substituters;
      extra-trusted-public-keys = helpers.nix.trustedPublicKeys;
    };
  };

  nixpkgs.config.allowUnfree = true;
}
