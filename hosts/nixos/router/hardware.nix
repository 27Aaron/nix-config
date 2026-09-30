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

    loader = {
      systemd-boot = {
        enable = true;
        editor = false;
        # Keep fewer generations: installed kernels are ~50M each and the ESP
        # is only 256M.
        configurationLimit = 4;
      };
      efi.canTouchEfiVariables = true;
    };
  };

  # Proxmox uses the guest agent for clean shutdown and IP reporting.
  services.qemuGuest.enable = true;

  # Keep the balloon driver disabled so the host cannot starve this VM.
  hardware'.disable-balloon.enable = true;

  # Storage: disko layout and preservation, provided by the shared modules.
  hardware' = {
    disko = {
      enable = true;
      device = "/dev/sda";
      tmpfsSize = "512M";
    };
    persistence.enable = true;
  };
}
