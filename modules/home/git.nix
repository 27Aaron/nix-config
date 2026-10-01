{ email, fullName, pkgs, ... }:
{
  programs = {
    git = {
      enable = true;
      lfs.enable = true;
      settings = {
        user = {
          name = fullName;
          email = email;
        };

        fetch.prune = true;
        init.defaultBranch = "main";
        log.date = "iso";
        pull.rebase = true;
        push.autoSetupRemote = true;
      };
    };

    delta = {
      enable = true;
      enableGitIntegration = true;
      options = {
        diff-so-fancy = true;
        line-numbers = true;
        true-color = "always";
      };
    };

    lazygit.enable = true;
  };

  home.packages = [
    pkgs.gh
    pkgs.git-trim
  ];
}
