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

        # Home Manager previews must not create files, including redirects.
        if [[ -v DRY_RUN ]]; then
          echo "Would initialize editable Karabiner configuration in $dir"
          exit 0
        fi

        umask 077
        mkdir -p -- "$(dirname -- "$dir")"
        work=$(mktemp -d -- "$dir.activation.XXXXXX")
        cleanup() {
          local activationStatus=$?
          if [[ -L "$work/old-link" && ! -e "$dir" && ! -L "$dir" ]]; then
            if ! mv -T -- "$work/old-link" "$dir"; then
              echo "Could not restore Karabiner link; recovery files are in $work" >&2
              exit 1
            fi
          fi
          rm -rf -- "$work"
          exit "$activationStatus"
        }
        trap cleanup EXIT
        trap 'exit 1' HUP INT TERM

        # Prepare both files before replacing any existing configuration.
        jq -e . "$gen" > "$work/karabiner.json"
        install -m 600 -- "$gen" "$work/marker"

        activeDir="$dir"
        if [[ -L "$dir" ]]; then
          if [[ ! -d "$dir" ]]; then
            echo "Karabiner directory link is broken or does not point to a directory: $dir" >&2
            exit 1
          fi
          # Dereference the old directory without changing its source data.
          activeDir="$work/config"
          mkdir -- "$activeDir"
          cp -RL -- "$dir/." "$activeDir/"
          chmod -R u+rwX -- "$activeDir"
        else
          mkdir -p -- "$dir"
        fi
        target="$activeDir/karabiner.json"
        marker="$activeDir/.nix-generated-karabiner.json"

        for file in "$target" "$marker"; do
          if [[ -e "$file" && ! -f "$file" ]]; then
            echo "Expected a regular Karabiner configuration file: $file" >&2
            exit 1
          fi
        done

        # An unchanged template preserves edits, but a JSON link must be replaced.
        if [[ -f "$target" && ! -L "$target" && -f "$marker" ]] && cmp -s -- "$gen" "$marker"; then
          chmod 600 -- "$target"
        else
          if [[ -e "$target" || -L "$target" ]]; then
            # A backup must survive store GC, even if the old JSON was a link.
            cp -L -- "$target" "$work/backup"
            chmod 600 -- "$work/backup"
            mv -fT -- "$work/backup" "$target.hm-bak"
            echo "Karabiner configuration backed up to $dir/karabiner.json.hm-bak"
          fi
          mv -fT -- "$work/karabiner.json" "$target"
        fi
        # Replace rather than overwrite: old markers may be read-only or links.
        mv -fT -- "$work/marker" "$marker"

        if [[ "$activeDir" != "$dir" ]]; then
          # Replace the directory link before Home Manager cleans old links.
          mv -T -- "$dir" "$work/old-link"
          mv -T -- "$activeDir" "$dir"
        fi
      )
    '';
  };
}
