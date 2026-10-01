{ username, ... }:
{
  # Load Home Manager modules that require nix-darwin.
  home-manager.users.${username}.imports = [
    ./karabiner.nix
    ./nh.nix
  ];
}
