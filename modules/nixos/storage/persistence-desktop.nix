{
  config,
  lib,
  myvars,
  ...
}: let
  cfg = config.storage'.persistence;
  user = myvars.username;
  hmApps = config.home-manager.users.${user}.home'.apps;
in {
  config = lib.mkIf cfg.desktop.enable {
    # Shared desktop state is enabled as a group; application state below is
    # added only when the corresponding feature is enabled.
    preservation'.user.directories =
      [
        {
          directory = ".config/gtk-3.0";
          mode = "0700";
        }
        {
          directory = ".config/dconf";
          mode = "0700";
        }
        {
          directory = ".local/share/keyrings";
          mode = "0700";
        }
        {
          directory = ".local/share/pki";
          mode = "0700";
        }
      ]
      ++ lib.optionals config.desktop'.applications.enable [
        # Desktop application launchers and file manager metadata
        {
          directory = ".local/share/applications";
          mode = "0700";
        }
        {
          directory = ".local/share/Trash";
          mode = "0700";
        }
        {
          directory = ".local/share/gvfs-metadata";
          mode = "0700";
        }
      ]
      ++ lib.optionals config.desktop'.dms.enable [
        # DankMaterialShell
        ".config/DankMaterialShell"
        {
          directory = ".local/state/DankMaterialShell";
          mode = "0700";
        }
      ]
      ++ lib.optionals config.desktop'.fcitx5.enable [
        # Fcitx5
        ".config/fcitx5"
        ".local/share/fcitx5"
      ]
      ++ lib.optionals hmApps.firefox.enable [
        # Firefox
        ".config/mozilla"
        ".mozilla"
      ]
      ++ lib.optionals config.desktop'.niri.enable [
        # Niri
        ".config/niri"
      ]
      ++ lib.optionals (config.desktop'.cursors.enable || config.desktop'.themes.enable) [
        # GTK and icon themes
        ".icons"
      ]
      ++ lib.optionals hmApps.telegram.enable [
        # Telegram
        ".local/share/AyuGramDesktop"
      ]
      ++ lib.optionals (config.services.pulseaudio.enable || config.services.pipewire.pulse.enable) [
        # PulseAudio compatibility cookie
        {
          directory = ".config/pulse";
          mode = "0700";
        }
      ]
      ++ lib.optionals hmApps.vscode.enable [
        # Visual Studio Code
        ".config/Code"
        ".vscode"
        ".vscode-shared"
      ]
      ++ lib.optionals config.services.pipewire.wireplumber.enable [
        # WirePlumber
        {
          directory = ".local/state/wireplumber";
          mode = "0700";
        }
      ];

    preservation'.os.directories =
      lib.optionals config.services.accounts-daemon.enable [
        {
          directory = "/var/lib/AccountsService";
          mode = "0775";
        }
      ]
      ++ lib.optionals config.hardware.bluetooth.enable [
        # Bluetooth
        {
          directory = "/var/lib/bluetooth";
          mode = "0700";
        }
      ]
      ++ lib.optionals config.services.power-profiles-daemon.enable [
        # Power management
        "/var/lib/power-profiles-daemon"
      ]
      ++ lib.optionals config.services.upower.enable [
        "/var/lib/upower"
      ]
      ++ lib.optionals config.services.greetd.enable [
        # Tuigreet
        {
          directory = "/var/cache/tuigreet";
          user = "greeter";
          group = "greeter";
        }
      ];
  };
}
