{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}: let
  brewCfg = osConfig.apps'.homebrew;
  enabled = brewCfg.enable && lib.elem "karabiner-elements" brewCfg.casks;
  writableDir = "${config.xdg.dataHome}/karabiner/config";

  # Only used when neither an existing configuration nor a writable copy exists.
  initialConfig = builtins.toFile "karabiner-initial.json" (builtins.toJSON {
    profiles = [
      {
        complex_modifications = {
          rules = [
            {
              description = "Change right_command key to command+control+option+shift. (Post f19 key when pressed alone)";
              manipulators = [
                {
                  from = {
                    key_code = "right_command";
                    modifiers.optional = ["any"];
                  };
                  to = [
                    {
                      key_code = "left_shift";
                      modifiers = [
                        "left_command"
                        "left_control"
                        "left_option"
                      ];
                    }
                  ];
                  to_if_alone = [
                    {
                      key_code = "f19";
                    }
                  ];
                  type = "basic";
                }
              ];
            }
            {
              description = "Click Control => Capslock , Long press Control => Control";
              manipulators = [
                {
                  from = {
                    key_code = "left_control";
                    modifiers.optional = ["any"];
                  };
                  to = [
                    {
                      key_code = "left_control";
                    }
                  ];
                  to_if_alone = [
                    {
                      hold_down_milliseconds = 100;
                      key_code = "caps_lock";
                    }
                  ];
                  type = "basic";
                }
              ];
            }
          ];
        };
        devices = [
          {
            disable_built_in_keyboard_if_exists = true;
            identifiers = {
              is_keyboard = true;
              product_id = 33;
              vendor_id = 1278;
            };
          }
        ];
        name = "Default profile";
        selected = true;
        virtual_hid_keyboard = {
          keyboard_type_v2 = "ansi";
        };
      }
    ];
  });
in {
  config = lib.mkIf enabled {
    # Karabiner watches the directory; its JSON must remain a writable file.
    xdg.configFile."karabiner".source = config.lib.file.mkOutOfStoreSymlink writableDir;

    home.activation.initializeKarabiner = lib.hm.dag.entryBetween ["linkGeneration"] ["writeBoundary"] ''
      initializeKarabinerConfig() (
        set -e
        export PATH="${lib.makeBinPath [pkgs.coreutils]}:$PATH"
        umask 077
        current=$1
        target=$2
        seed=$3

        if [[ -e "$target" || -L "$target" ]]; then
          if [[ ! -d "$target" ]]; then
            echo "Karabiner configuration target is not a directory: $target" >&2
            exit 1
          fi
          exit 0
        fi

        mkdir -p -- "$(dirname "$target")"
        staging="$(mktemp -d "$target.XXXXXX")"
        trap 'rm -rf -- "$staging"' EXIT

        if [[ -d "$current" ]]; then
          cp -RL --no-preserve=mode -- "$current/." "$staging/"
        fi
        if [[ ! -f "$staging/karabiner.json" ]]; then
          cp -- "$seed" "$staging/karabiner.json"
        fi

        chmod -R u+rwX -- "$staging"
        mv -T --no-clobber -- "$staging" "$target"
      )

      run initializeKarabinerConfig \
        ${lib.escapeShellArg "${config.xdg.configHome}/karabiner"} \
        ${lib.escapeShellArg writableDir} \
        ${lib.escapeShellArg initialConfig}
      unset -f initializeKarabinerConfig
    '';
  };
}
