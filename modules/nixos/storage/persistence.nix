{
  config,
  inputs,
  lib,
  myvars,
  ...
}: let
  cfg = config.storage'.persistence;
  user = myvars.username;
  hm = config.home-manager.users.${user};
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

    # Baseline user state shared by every host. State owned by a feature is
    # declared in that feature's module; Home Manager tools report theirs via
    # persist' and get spliced in here.
    preservation'.user.directories =
      [
        # Keep caches off the tmpfs root to avoid excessive RAM usage.
        {
          directory = ".cache";
          mode = "0700";
        }

        # Nix and Home Manager
        ".local/share/nix"
        ".local/state/home-manager"
        ".local/state/nix/profiles"

        # Credentials without a managing module live here.
        {
          directory = ".gnupg";
          mode = "0700";
        }
      ]
      ++ hm.persist'.directories;

    preservation'.user.files = hm.persist'.files;

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
