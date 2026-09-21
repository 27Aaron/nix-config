# nix-darwin has no programs.nh module, so nh is enabled through Home Manager.
{ helpers, ... }:
{
  programs.nh = {
    enable = true;
    flake = helpers.path.nixConfig;
  };
}
