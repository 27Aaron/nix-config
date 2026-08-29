{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.tools'.ai-cli;
in {
  options.tools'.ai-cli.enable = lib.mkEnableOption "AI coding CLIs (Claude Code and Codex)";

  config = lib.mkIf cfg.enable {
    hm'.home.packages = with pkgs; [
      claude-code
      codex
    ];

    hm'.home.shellAliases = {
      cc = "claude --dangerously-skip-permissions";
      cx = "codex --dangerously-bypass-approvals-and-sandbox";
    };

    hm'.persist' = {
      directories = [
        ".claude"
        ".codex"
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
