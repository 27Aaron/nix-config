{ pkgs, ... }:
{
  home.packages = with pkgs; [
    btop
    curl
    dust
    duf
    fd
    fastfetch
    fzf
    git
    git-lfs
    jq
    just
    neovim
    ripgrep
    uv
    wget
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
