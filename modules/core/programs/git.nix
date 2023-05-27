{
  hm'.programs = {
    git = {
      enable = true;
      lfs.enable = true;
      settings = {
        user = {
          name = "Aaron";
          email = "85681241+27Aaron@users.noreply.github.com";
        };
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
