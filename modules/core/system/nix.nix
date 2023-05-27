{lib, ...}: {
  nix = {
    # remove nix-channel related tools & configs, we use flakes instead.
    channel.enable = false;

    # do garbage collection weekly to keep disk usage low
    gc = {
      automatic = lib.mkDefault true;
      dates = lib.mkDefault "weekly";
      options = lib.mkDefault "--delete-older-than 7d";
    };

    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
      trusted-users = [
        "@wheel"
      ];
      substituters = [
        "https://cache.garnix.io"
      ];
      trusted-public-keys = [
        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
      ];
    };
  };

  # to install chrome, you need to enable unfree packages
  nixpkgs.config.allowUnfree = lib.mkForce true;

  preservation'.user.directories = [
    ".cache/nix"
    ".local/share/nix"
    ".local/state/home-manager"
    ".local/state/nix/profiles"
  ];
}
