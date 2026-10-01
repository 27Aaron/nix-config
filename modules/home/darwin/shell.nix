{ lib, ... }:
{
  # Set up Homebrew before the shared shell integrations.
  programs.fish.interactiveShellInit = lib.mkBefore ''
    if test -x /opt/homebrew/bin/brew
      eval (/opt/homebrew/bin/brew shellenv fish)
    end
  '';

  programs.zsh.initContent = lib.mkBefore ''
    if [ -x /opt/homebrew/bin/brew ]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
  '';
}
