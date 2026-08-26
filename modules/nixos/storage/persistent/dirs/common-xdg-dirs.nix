{
  preservation'.user.directories = [
    # These are separate bind mounts on the ephemeral home. GLib treats them
    # as system-internal mounts, so explicitly allow GIO/Nautilus trash support.
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
  ];
}
