{pkgs, ...}: {
  programs.fish = {
    enable = true;
    useBabelfish = true;
    shellInit = ''
      fish_vi_key_bindings
    '';
  };

  user'.shell = pkgs.fish;
}
