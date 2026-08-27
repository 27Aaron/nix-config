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
    # Install a plain editable karabiner.json; reinstall only when the Nix
    # rules changed, keeping manual and Karabiner-GUI edits otherwise.
    home.activation.initializeKarabiner = lib.hm.dag.entryBetween ["linkGeneration"] ["writeBoundary"] ''
      (
        set -eu
        export PATH="${lib.makeBinPath [pkgs.coreutils pkgs.jq]}:$PATH"
        dir=${lib.escapeShellArg "${config.xdg.configHome}/karabiner"}
        gen=${lib.escapeShellArg generatedConfig}
        umask 077
        target="$dir/karabiner.json"
        marker="$dir/.nix-generated-karabiner.json"
        mkdir -p -- "$dir"

        # Same rules as the last install: leave the editable file alone.
        if [[ -f "$target" && -f "$marker" ]] && cmp -s -- "$gen" "$marker"; then
          exit 0
        fi

        jq . "$gen" > "$target.new"
        if [[ -f "$target" ]]; then
          mv -- "$target" "$target.hm-bak"
          echo "Karabiner configuration backed up to $target.hm-bak"
        fi

        mv -- "$target.new" "$target"
        cp -- "$gen" "$marker"
      )
    '';
  };
}
