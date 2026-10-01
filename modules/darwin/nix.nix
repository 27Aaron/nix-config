{ pkgs, ... }:
{
  # Nix language tooling.
  environment.systemPackages = with pkgs; [
    deadnix
    nil
    nixd
  ];

  # Nix daemon, flakes, and automatic store optimisation.
  nix = {
    enable = true;
    package = pkgs.nix;
    channel.enable = false;
    optimise.automatic = true;

    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  nixpkgs.config.allowUnfree = true;
}
