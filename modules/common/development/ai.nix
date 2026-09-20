{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.development'.ai;
  agentPackages = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  options.development'.ai = {
    enable = lib.mkEnableOption "AI development tools";
  };

  config = lib.mkIf cfg.enable {
    # Install the CLI packages only; leaving settings unmanaged keeps HM from
    # taking over the live files inside ~/.claude and ~/.codex.
    hm'.home.packages = with agentPackages; [
      chatgpt
      claude-code
      codex
      grok
    ];

    hm'.home.shellAliases = {
      cc = "claude --dangerously-skip-permissions";
      cx = "codex --dangerously-bypass-approvals-and-sandbox";
    };

    # Credentials and session state; keep them private to the user. Reported
    # through persist' so the module stays platform-neutral: the NixOS
    # persistence module splices these entries in, darwin ignores them.
    hm'.persist'.directories = [
      {
        directory = ".claude";
        mode = "0700";
      }
      {
        directory = ".codex";
        mode = "0700";
      }
      {
        directory = ".grok";
        mode = "0700";
      }
    ];

    hm'.persist'.files = [
      {
        file = ".claude.json";
        how = "bindmount";
        mode = "0600";
      }
    ];
  };
}
