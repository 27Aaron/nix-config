# Router hardware: QEMU guest setup and storage.
{ modulesPath, ... }:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  boot = {
    # net.ifnames=0 gives the NIC a classic eth0 name; audit=0 silences the
    # kernel audit log, which is pure noise on a home router VM.
    kernelParams = [
      "audit=0"
      "net.ifnames=0"
    ];
  };

  hardware'.systemd-boot.enable = true;
  # Keep fewer generations: installed kernels are ~50M each and the ESP
  # is only 256M.
  boot.loader.systemd-boot.configurationLimit = 4;

  # Proxmox uses the guest agent for clean shutdown and IP reporting.
  services.qemuGuest.enable = true;

  # Keep the balloon driver disabled so the host cannot starve this VM.
  hardware'.disable-balloon.enable = true;

  # Storage: disko layout and preservation, provided by the shared modules.
  hardware'.disko.enable = true;
  hardware'.disko.device = "/dev/sda";
  hardware'.disko.tmpfsSize = "512M";

  hardware'.persistence.enable = true;
}
