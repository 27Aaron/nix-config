{
  email,
  fullName,
  pkgs,
  username,
  ...
}:
let
  homeDirectory = if pkgs.stdenv.hostPlatform.isDarwin then "/Users/${username}" else "/home/${username}";
in
{
  # Home Manager is embedded in the platform system.
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-bak";
    extraSpecialArgs = {
      inherit email fullName username;
    };

    users.${username} = {
      imports = [
        ./common/development.nix
        ./common/git.nix
        ./common/kitty.nix
        ./common/shell.nix
        ./common/tools.nix
      ];

      home = {
        username = username;
        inherit homeDirectory;
        language.collate = "C.UTF-8";
        stateVersion = "26.05";
      };

      programs.home-manager.enable = true;
      programs.man.enable = false;
      manual.manpages.enable = false;
    };
  };
}
