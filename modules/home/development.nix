{ ... }:
{
  # Enable mise without managing its global tool versions here.
  programs.mise = {
    enable = true;
    enableFishIntegration = true;
    enableZshIntegration = true;
  };

  # Install uv through Home Manager.
  programs.uv.enable = true;
}
