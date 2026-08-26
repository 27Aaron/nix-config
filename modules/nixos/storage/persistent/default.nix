{
  inputs,
  lib,
  myvars,
  ...
}: let
  user = myvars.username;
in {
  imports = [
    inputs.preservation.nixosModules.default

    (lib.mkAliasOptionModule ["preservation'" "os"] ["preservation" "preserveAt" "/persistent"])
    (lib.mkAliasOptionModule
      ["preservation'" "user"]
      ["preservation" "preserveAt" "/persistent" "users" user])
  ];

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
}
