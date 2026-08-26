{
  config,
  inputs,
  lib,
  myvars,
  ...
}: let
  cfg = config.storage'.persistence;
  user = myvars.username;
in {
  imports = [
    inputs.preservation.nixosModules.default

    (lib.mkAliasOptionModule ["preservation'" "os"] ["preservation" "preserveAt" "/persistent"])
    (lib.mkAliasOptionModule
      ["preservation'" "user"]
      ["preservation" "preserveAt" "/persistent" "users" user])
  ];

  options.storage'.persistence = {
    enable = lib.mkEnableOption "Preservation for an ephemeral NixOS root";

    desktop.enable = lib.mkEnableOption "Persistence entries for desktop applications";
  };

  config = lib.mkIf cfg.enable {
    boot = {
      initrd.systemd.enable = true;
      tmp.cleanOnBoot = true;
    };

    # Preservation needs the persistent storage in the initrd for machine-id.
    fileSystems."/persistent".neededForBoot = true;

    preservation = {
      enable = true;
      preserveAt."/persistent".commonMountOptions = [
        "x-gdu.hide"
        "x-gvfs-hide"
      ];
    };

    # Common user state shared by the always-enabled home modules.
    preservation'.user = {
      directories = [
        # Keep caches off the tmpfs root to avoid excessive RAM usage.
        {
          directory = ".cache";
          mode = "0700";
        }

        # AI assistants
        ".codex"
        ".claude"

        # Atuin
        {
          directory = ".atuin";
          mode = "0700";
        }
        ".local/share/atuin"

        # GNUPG
        {
          directory = ".gnupg";
          mode = "0700";
        }

        # Nix and Home Manager
        ".local/share/nix"
        ".local/state/home-manager"
        ".local/state/nix/profiles"

        # Configuration and credentials
        {
          directory = "nix-config";
          mode = "0700";
        }
        {
          directory = ".ssh";
          mode = "0700";
        }

        # XDG user directories
        {
          directory = "Desktop";
          mountOptions = ["x-gvfs-trash"];
        }
        {
          directory = "Documents";
          mountOptions = ["x-gvfs-trash"];
        }
        {
          directory = "Downloads";
          mountOptions = ["x-gvfs-trash"];
        }
        {
          directory = "Music";
          mountOptions = ["x-gvfs-trash"];
        }
        {
          directory = "Pictures";
          mountOptions = ["x-gvfs-trash"];
        }
        {
          directory = "Videos";
          mountOptions = ["x-gvfs-trash"];
        }

        # Zoxide
        ".local/share/zoxide"
      ];

      files = [
        {
          file = ".claude.json";
          how = "bindmount";
        }
      ];
    };

    # Common NixOS state required by the base system.
    preservation'.os = {
      directories = [
        {
          directory = "/var/lib/nixos";
          inInitrd = true;
        }
        "/var/lib/lastlog"
        "/var/lib/systemd"
        "/var/log"
        {
          directory = "/var/tmp";
          mode = "1777";
        }
      ];

      files = [
        {
          file = "/etc/machine-id";
          inInitrd = true;
        }
      ];
    };

    # systemd-machine-id-commit.service would fail, but it is not relevant
    # in this specific setup for a persistent machine-id so we disable it.
    systemd.suppressedSystemUnits = ["systemd-machine-id-commit.service"];

    # Let the service commit the transient ID to the persistent volume.
    systemd.services.systemd-machine-id-commit = {
      unitConfig.ConditionPathIsMountPoint = [
        ""
        "/persistent/etc/machine-id"
      ];
      serviceConfig.ExecStart = [
        ""
        "systemd-machine-id-setup --commit --root /persistent"
      ];
    };
  };
}
