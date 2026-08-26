{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.hardware'.amdgpu;
in {
  options.hardware'.amdgpu.enable = lib.mkEnableOption "AMD GPU support";

  config = lib.mkIf cfg.enable {
    hardware.graphics = {
      enable = true;

      # Rusticl provides OpenCL through Mesa and supports the Radeon 780M
      # without pulling in the considerably larger ROCm stack.
      extraPackages = [pkgs.mesa.opencl];
    };

    environment = {
      sessionVariables.RUSTICL_ENABLE = "radeonsi";

      systemPackages = with pkgs; [
        amdgpu_top
        clinfo
        libva-utils
        mesa-demos
        nvtopPackages.amd
        pciutils
        vulkan-tools
      ];
    };
  };
}
