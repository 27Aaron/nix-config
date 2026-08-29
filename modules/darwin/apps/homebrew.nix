{
  config,
  lib,
  ...
}: let
  cfg = config.apps'.homebrew;
in {
  options.apps'.homebrew = {
    enable = lib.mkEnableOption "Homebrew package management";

    enableFishIntegration = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Homebrew integration for Fish";
    };

    enableZshIntegration = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Homebrew integration for Zsh";
    };

    onActivation = {
      autoUpdate = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Fetch the newest stable Homebrew branch on activation";
      };

      cleanup = lib.mkOption {
        type = lib.types.enum ["none" "uninstall" "zap"];
        default = "zap";
        description = "How aggressively to remove packages not in the configuration";
      };

      upgrade = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Upgrade outdated Homebrew packages on activation";
      };
    };

    masApps = lib.mkOption {
      type = lib.types.attrsOf lib.types.int;
      default = {
        "Bob" = 1630034110;
        "WPS" = 1443749478;
      };
      description = "Applications to install from the Mac App Store";
    };

    brews = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        # Disk & Cleanup
        "mole"
      ];
      description = "Homebrew formulae to install";
    };

    casks = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        # AI Development
        "chatgpt"
        "cc-switch"
        "grok-build"
        "steipete/tap/codexbar"

        # Browser
        # "brave-browser"
        "firefox"
        "google-chrome"

        # Communication
        "feishu"
        "telegram"
        "wechat"

        # Development
        "orbstack"

        # Editor
        "visual-studio-code"

        # Font
        "font-lxgw-wenkai"
        "font-hack-nerd-font"
        "font-material-icons"
        "font-maple-mono-nf-cn"
        "font-jetbrains-mono-nerd-font"

        # Hardware
        # "monitorcontrol"
        "macs-fan-control"

        # Input & Keyboard
        "input-source-pro"
        "karabiner-elements"

        # Knowledge Base
        "obsidian"

        # Media
        "iina"
        "neteasemusic"
        "obs"
        "plex"

        # Menu Bar
        "jordanbaird-ice@beta"

        # Network Tools
        "surge"

        # Productivity
        "qspace-pro"
        "raycast"

        # Remote Access
        "uuremote"

        # SSH Client
        "termius"

        # System Monitor
        "stats"

        # Terminal Emulator
        "ghostty"
        "kitty"
      ];
      description = "Homebrew casks to install";
    };
  };

  config = lib.mkIf cfg.enable {
    homebrew = {
      enable = true;
      inherit (cfg) enableFishIntegration enableZshIntegration masApps brews casks;
      onActivation = cfg.onActivation;
    };
  };
}
