{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  cfg = config.tools'.coding-agents;
  dsh = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.dsh;
in {
  options.tools'.coding-agents = {
    enable = lib.mkEnableOption "AI coding agents";
  };

  config = lib.mkIf cfg.enable {
    # Bare enable only installs the packages; leaving settings unmanaged keeps
    # HM from taking over the live files inside ~/.claude and ~/.codex.
    hm'.programs.claude-code.enable = true;
    hm'.programs.codex.enable = true;

    hm'.home.packages = [dsh];

    hm'.home.shellAliases = {
      cc = "claude --dangerously-skip-permissions";
      cx = "codex --dangerously-bypass-approvals-and-sandbox";
    };

    hm'.persist' = {
      directories = [
        ".claude"
        ".codex"
        ".dsh"
      ];

      files = [
        {
          file = ".claude.json";
          how = "bindmount";
        }
      ];
    };
  };
}
