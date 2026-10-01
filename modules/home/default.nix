{
  email,
  fullName,
  username,
  ...
}:
{
  # Home Manager is embedded in the Darwin system.
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-bak";
    extraSpecialArgs = {
      inherit email fullName username;
    };

    users.${username} = {
      imports = [
        ./development.nix
        ./git.nix
        ./karabiner.nix
        ./kitty.nix
        ./nh.nix
        ./shell.nix
        ./tools.nix
      ];

      home = {
        username = username;
        homeDirectory = "/Users/${username}";
        language.collate = "C.UTF-8";
        stateVersion = "26.05";
      };

      programs.home-manager.enable = true;
      programs.man.enable = false;
      manual.manpages.enable = false;
    };
  };
}
