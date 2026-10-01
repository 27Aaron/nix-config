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
    gawk
    git
    git-lfs
    gnugrep
    gnused
    iperf3
    jq
    just
    ncdu
    neovim
    nload
    nmap
    ripgrep
    socat
    wget
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
