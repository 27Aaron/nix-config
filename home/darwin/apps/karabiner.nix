{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}: let
  brewCfg = osConfig.apps'.homebrew;
  enabled = brewCfg.enable && lib.elem "karabiner-elements" brewCfg.casks;
  generatedConfig = builtins.toFile "karabiner.json" (builtins.toJSON {
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
    # Keep one backup, then install a writable file on every activation.
    home.activation.initializeKarabiner = lib.hm.dag.entryBetween ["linkGeneration"] ["writeBoundary"] ''
      (
        set -eu
        export PATH="${lib.makeBinPath [pkgs.coreutils pkgs.jq]}:$PATH"
        dir=${lib.escapeShellArg "${config.xdg.configHome}/karabiner"}
        gen=${lib.escapeShellArg generatedConfig}

        if [[ -v DRY_RUN ]]; then
          echo "Would back up and install editable Karabiner configuration in $dir"
          exit 0
        fi
        if [[ -L "$dir" ]]; then
          echo "Replace the Karabiner directory link with a regular directory first: $dir" >&2
          exit 1
        fi

        umask 077
        mkdir -p -- "$dir"
        target="$dir/karabiner.json"
        work=$(mktemp -d -- "$dir/.activation.XXXXXX")
        trap 'rm -rf -- "$work"' EXIT
        trap 'exit 1' HUP INT TERM

        jq -e . "$gen" > "$work/karabiner.json"
        if [[ -f "$target" ]]; then
          cp -L -- "$target" "$work/backup"
          chmod 600 -- "$work/backup"
          mv -fT -- "$work/backup" "$target.hm-bak"
          # Remove timestamped backups left by the earlier implementation.
          rm -f -- "$dir"/karabiner.json.bak.*
        fi
        mv -fT -- "$work/karabiner.json" "$target"
        rm -f -- "$dir/.nix-generated-karabiner.json"
      )
    '';
  };
}
