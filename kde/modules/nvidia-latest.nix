{ config, lib, pkgs, ... }:

{
  # MochaKde / NVIDIA latest
  #
  # Objetivo:
  #   casar o kernel Caninana 7.0.3 com o driver NVIDIA mais recente
  #   disponivel em config.boot.kernelPackages.nvidiaPackages.latest.
  #
  # Para RTX 50 / driver moderno, este experimento usa open = true.
  # Se o build/eval recusar, o processo para antes do boot.

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.nvidia = {
    modesetting.enable = true;

    open = lib.mkForce true;

    nvidiaSettings = true;

    powerManagement.enable = true;
    powerManagement.finegrained = false;

    package = config.boot.kernelPackages.nvidiaPackages.latest;
  };

  boot.kernelParams = [
    "nvidia-drm.modeset=1"
    "nvidia-drm.fbdev=1"
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
  ];

  boot.extraModprobeConfig = ''
    options nvidia NVreg_TemporaryFilePath=/var/tmp
  '';

  environment.systemPackages = with pkgs; [
    nvtopPackages.nvidia
    vulkan-tools
    mesa-demos
  ];

  assertions = [
    {
      assertion = config.hardware.nvidia.package.version == config.boot.kernelPackages.nvidiaPackages.latest.version;
      message = ''
        MochaKde abortado:
        hardware.nvidia.package nao e kernelPackages.nvidiaPackages.latest.

        package:
          ${config.hardware.nvidia.package.version}

        latest:
          ${config.boot.kernelPackages.nvidiaPackages.latest.version}
      '';
    }
  ];

  environment.etc."mocha-kde/nvidia-latest.txt".text = ''
    source = config.boot.kernelPackages.nvidiaPackages.latest
    evaluated_version = ${config.hardware.nvidia.package.version}
    open_kernel_module = true
    experiment = caninana-703-nvidia-latest
  '';
}
