{lib, ...}: {
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
      builders-use-substitutes = true;
    };
  };

  nixpkgs.config.allowUnfree = true;
}
