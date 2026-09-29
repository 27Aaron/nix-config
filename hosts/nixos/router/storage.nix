# Router storage: disko layout and preservation, both provided by the shared
# modules under modules/nixos/.
{
  hardware'.disko = {
    enable = true;
    device = "/dev/sda";
    tmpfsSize = "512M";
  };

  hardware'.persistence.enable = true;
}
