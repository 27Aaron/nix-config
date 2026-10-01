{
  email,
  fullName,
  username,
  ...
}:
{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-bak";
    extraSpecialArgs = {
      inherit email fullName username;
    };

    users.${username} = {
      imports = [
        ./git.nix
        ./shell.nix
        ./tools.nix
      ];

      home = {
        username = username;
        homeDirectory = "/Users/${username}";
        stateVersion = "26.05";
      };

      programs.home-manager.enable = true;
    };
  };
}
