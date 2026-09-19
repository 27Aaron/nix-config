{
  helpers,
  lib,
  platformName,
  ...
}:
{
  nix = {
    # remove nix-channel related tools & configs, we use flakes instead.
    channel.enable = false;

    gc = {
      automatic = lib.mkDefault true;
      options = lib.mkDefault "--delete-older-than 7d";
      # NixOS would otherwise run daily at 03:15; nix-darwin has no gc.dates
      # and runs weekly through its own gc.interval default.
      dates = lib.mkIf (platformName == "nixos") (lib.mkDefault "weekly");
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
