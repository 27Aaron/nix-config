{ myvars, ... }:
{
  programs = {
    git = {
      enable = true;
      lfs.enable = true;
      settings.user = {
        name = myvars.fullName;
        email = myvars.email;
      };
    };

    delta = {
      enable = true;
      options = {
        diff-so-fancy = true;
        line-numbers = true;
        true-color = "always";
      };
    };
  };
}
