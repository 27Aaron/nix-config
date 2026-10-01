{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    deadnix
    nil
    nixd
  ];

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
