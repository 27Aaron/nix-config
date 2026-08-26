{
  myvars,
  pkgs,
  ...
}: {
  programs.fish = {
    enable = true;
    useBabelfish = true;
    shellInit = ''
      fish_vi_key_bindings
    '';
  };

  users.users.${myvars.username}.shell = pkgs.fish;
}
