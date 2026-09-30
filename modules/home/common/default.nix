{ myvars, ... }:
{
  imports = [
    ./atuin.nix
    ./eza.nix
    ./fish.nix
    ./git.nix
    ./misc.nix
    ./starship.nix
    ./zoxide.nix
    ./zsh.nix
  ];

  home = {
    username = myvars.username;
    stateVersion = "26.05";

    # better ls sorting
    language.collate = "C.UTF-8";
  };

  # The second switch is what skips building the option manual; man.enable alone does not.
  programs.man.enable = false;
  manual.manpages.enable = false;
}
