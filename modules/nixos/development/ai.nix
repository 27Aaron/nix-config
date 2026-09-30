{
  config,
  lib,
  ...
}:
let
  cfg = config.development'.ai;
in
{
  options.development'.ai = {
    enable = lib.mkEnableOption "AI development tools";
  };

  config = lib.mkIf cfg.enable {
    # Credentials and session state; keep them private to the user.
    preservation'.user.directories = [
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

    preservation'.user.files = [
      {
        file = ".claude.json";
        how = "bindmount";
        mode = "0600";
      }
    ];
  };
}
