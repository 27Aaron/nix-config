# QEMU guest setup: virtio drivers come from the qemu-guest profile, and the
# balloon driver stays disabled so the host cannot starve this VM.
{ modulesPath, pkgs, ... }:
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

    extraModprobeConfig = ''
      blacklist virtio_balloon
      install virtio_balloon ${pkgs.coreutils}/bin/true

      # Reject modules mitigating the Dirty Frag LPE (esp4, esp6, rxrpc).
      # Harmless unless IPsec ESP or AF_RXRPC is actually used.
      install esp4 ${pkgs.coreutils}/bin/false
      install esp6 ${pkgs.coreutils}/bin/false
      install rxrpc ${pkgs.coreutils}/bin/false
    '';
  };

  # Proxmox uses the guest agent for clean shutdown and IP reporting.
  services.qemuGuest.enable = true;
}
