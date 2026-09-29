{
  config,
  lib,
  myvars,
  pkgs,
  ...
}:
{
  # `programs.git` generates ~/.config/git/config, used only when ~/.gitconfig
  # is absent: https://git-scm.com/docs/git-config#Documentation/git-config.txt---global
  home.activation.removeExistingGitconfig = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
    rm -f ${config.home.homeDirectory}/.gitconfig
  '';

  programs = {
    git = {
      enable = true;
      lfs.enable = true;
      settings = {
        user = {
          name = myvars.fullName;
          email = myvars.email;
        };

        fetch.prune = true;
        init.defaultBranch = "main";
        log.date = "iso";
        pull.rebase = true;
        push.autoSetupRemote = true;
      };
    };

    # A syntax-highlighting pager for git, diff, grep, and blame output
    delta = {
      enable = true;
      enableGitIntegration = true;
      options = {
        diff-so-fancy = true;
        line-numbers = true;
        true-color = "always";
      };
    };

    # Git terminal UI.
    lazygit.enable = true;
  };

  # GitHub CLI, plus git-trim for pruning merged/stray branches.
  home.packages = [
    pkgs.gh
    pkgs.git-trim
  ];

  # Runtime state: GitHub CLI account settings and fallback credentials,
  # plus lazygit recent repositories.
  persist'.directories = [
    {
      directory = ".config/gh";
      mode = "0700";
    }
    ".local/state/lazygit"
  ];
}
