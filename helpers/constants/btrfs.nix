# Btrfs layout shared by the disko module, btrbk and Preservation.
{
  # Top-level volume that hosts every subvolume.
  pool = "/btr_pool";

  persistent = {
    subvolume = "@persistent";
    mountpoint = "/persistent";
  };

  # Mounted subvolume that holds the btrbk snapshots.
  snapshots = "/snapshots";
}
