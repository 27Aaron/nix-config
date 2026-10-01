{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  # Only manage the profile when the cask is enabled.
  enabled = lib.any (
    c:
    let
      name = if builtins.isAttrs c then c.name or "" else c;
    in
    name == "karabiner-elements"
  ) osConfig.homebrew.casks;

  generatedConfig = builtins.toFile "karabiner.json" (
    builtins.toJSON {
      profiles = [
        {
          complex_modifications.rules = [
            {
              description = "Map right command to a Hyper key and F19 when pressed alone";
              manipulators = [
                {
                  from = {
                    key_code = "right_command";
                    modifiers.optional = [ "any" ];
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
                  to_if_alone = [ { key_code = "f19"; } ];
                  type = "basic";
                }
              ];
            }
            {
              description = "Map left control to caps lock when tapped";
              manipulators = [
                {
                  from = {
                    key_code = "left_control";
                    modifiers.optional = [ "any" ];
                  };
                  to = [ { key_code = "left_control"; } ];
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
          virtual_hid_keyboard.keyboard_type_v2 = "ansi";
        }
      ];
    }
  );
in
{
  config = lib.mkIf enabled {
    # Write a GUI-editable copy; activation replaces it with the declared profile.
    home.activation.initializeKarabiner =
      lib.hm.dag.entryBetween [ "linkGeneration" ] [ "writeBoundary" ]
        ''
          (
            set -eu
            export PATH="${lib.makeBinPath [ pkgs.coreutils ]}:$PATH"
            dir=${lib.escapeShellArg "${config.xdg.configHome}/karabiner"}
            gen=${lib.escapeShellArg generatedConfig}

            if [[ -v DRY_RUN ]]; then
              echo "Would install editable Karabiner configuration in $dir"
              exit 0
            fi
            if [[ -L "$dir" ]]; then
              echo "Replace the Karabiner directory link with a regular directory first: $dir" >&2
              exit 1
            fi

            umask 077
            mkdir -p -- "$dir"
            tmp="$dir/.karabiner.json.tmp"
            install -m 600 -- "$gen" "$tmp"
            mv -fT -- "$tmp" "$dir/karabiner.json"
          )
        '';
  };
}
