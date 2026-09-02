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

      extra-substituters = ["https://cache.numtide.com"];
      extra-trusted-public-keys = [
        "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
      ];
    };
  };

  nixpkgs.config.allowUnfree = true;
}
