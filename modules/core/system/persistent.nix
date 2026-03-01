{
  lib,
  config,
  inputs,
  ...
}:
let
  user = config.core'.userName;
in
{
  imports = [
    inputs.preservation.nixosModules.default

    (lib.mkAliasOptionModule [ "preservation'" "os" ] [ "preservation" "preserveAt" "/persistent" ])
    (lib.mkAliasOptionModule
      [ "preservation'" "user" ]
      [ "preservation" "preserveAt" "/persistent" "users" user ]
    )
  ];

  boot.tmp.cleanOnBoot = true;

  preservation = {
    enable = true;
    preserveAt."/persistent" = {
      commonMountOptions = [
        "x-gdu.hide"
        "x-gvfs-hide"
      ];

      directories = [
        # Simple paths
        "/etc/NetworkManager/system-connections"
        "/var/lib/NetworkManager"
        "/var/lib/systemd"
        "/var/log"

        # Complex configurations
        {
          directory = "/etc/nixos/nix-config";
          mode = "0700";
          user = user;
          group = "users";
        }
        {
          directory = "/var/lib/machines";
          mode = "0700";
        }
        {
          directory = "/var/lib/nixos";
          inInitrd = true;
        }
        {
          directory = "/var/lib/private";
          mode = "0700";
        }
      ];

      files = [
        # auto-generated machine ID

        {
          file = "/etc/machine-id";
          inInitrd = true;
        }
      ];

      users.${user} = {
        directories = [
          # XDG Directories
          "Documents"
          "Downloads"
          "Music"
          "Pictures"
          "Videos"
        ];
      };
    };
  };

  # systemd-machine-id-commit.service would fail, but it is not relevant
  # in this specific setup for a persistent machine-id so we disable it
  #
  # see the firstboot example below for an alternative approach
  systemd.suppressedSystemUnits = [ "systemd-machine-id-commit.service" ];

  # let the service commit the transient ID to the persistent volume
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
}
