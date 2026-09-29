{
  nix = {
    channel.enable = false;

    gc = {
      automatic = true;
      options = "--delete-older-than 7d";
    };

    optimise.automatic = true;

    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];

      extra-substituters = [
        "https://cache.numtide.com" # llm-agents prebuilds (numtide)
      ];
      extra-trusted-public-keys = [
        "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g=" # cache.numtide.com
      ];
    };
  };

  nixpkgs.config.allowUnfree = true;
}
