{ username, ... }:
{
  nix = {
    channel.enable = false;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    optimise.automatic = true;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [ username ];
    };
  };

  nixpkgs.config.allowUnfree = true;
  preservation'.user.directories = [
    {
      directory = "nix-config";
      mode = "0700";
    }
  ];
}
