{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.tools'.ai;
  agentPackages = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  options.tools'.ai = {
    enable = lib.mkEnableOption "AI development tools";
  };

  config = lib.mkIf cfg.enable {
    # Bare enable only installs the packages; leaving settings unmanaged keeps
    # HM from taking over the live files inside ~/.claude and ~/.codex.
    hm'.programs.claude-code.enable = true;
    hm'.programs.codex.enable = true;

    hm'.home.packages = with agentPackages; [
      chatgpt
      dsh
      zcode
    ];

    hm'.home.shellAliases = {
      cc = "claude --dangerously-skip-permissions";
      cx = "codex --dangerously-bypass-approvals-and-sandbox";
    };

    preservation'.user = {
      # Credentials and session state; keep them private to the user.
      directories = [
        {
          directory = ".claude";
          mode = "0700";
        }
        {
          directory = ".codex";
          mode = "0700";
        }
        {
          directory = ".dsh";
          mode = "0700";
        }
        {
          directory = ".zcode";
          mode = "0700";
        }
      ];

      files = [
        {
          file = ".claude.json";
          how = "bindmount";
          mode = "0600";
        }
      ];
    };
  };
}
