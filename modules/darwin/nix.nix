{ pkgs, ... }:
{
  # Nix language tooling.
  environment.systemPackages = with pkgs; [
    deadnix
    nil
    nixd
  ];

  # Nix daemon, flakes, store optimisation, and automatic garbage collection.
  nix = {
    channel.enable = false;
    optimise.automatic = true;
    gc = {
      automatic = true;
      options = "--delete-older-than 7d";
    };

    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  nixpkgs.config.allowUnfree = true;
}
