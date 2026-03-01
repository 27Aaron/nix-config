{
  lib,
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    comma
    deadnix
    nil
    nix-index
    nix-output-monitor
    nix-prefetch-git
    nix-prefetch-github
    nix-serve
    nix-tree
    nixd
    nixpkgs-review
    nurl
    nvd
  ];

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
    ".cache/nixpkgs-review"
    ".local/share/nix"
    ".local/state/nix/profiles"
    ".local/state/home-manager"
  ];
}
