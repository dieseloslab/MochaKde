{ config, lib, pkgs, ... }:

let
  selectedKernelPackages =
    pkgs.cachyosKernels."linuxPackages-cachyos-bore-lto";

  selectedNvidia =
    if (selectedKernelPackages.nvidiaPackages.latest.version or "") == "595.71.05" then
      selectedKernelPackages.nvidiaPackages.latest
    else if (selectedKernelPackages.nvidiaPackages.production.version or "") == "595.71.05" then
      selectedKernelPackages.nvidiaPackages.production
    else if (selectedKernelPackages.nvidiaPackages.stable.version or "") == "595.71.05" then
      selectedKernelPackages.nvidiaPackages.stable
    else
      throw "703 bore-lto: nenhum NVIDIA 595.71.05 encontrado em nvidiaPackages latest/production/stable.";

  kernelVersion =
    config.boot.kernelPackages.kernel.version or "";

  kernelPname =
    config.boot.kernelPackages.kernel.pname or "";

  kernelModDirVersion =
    config.boot.kernelPackages.kernel.modDirVersion or "";

  nvidiaVersion =
    config.hardware.nvidia.package.version or "";

  nvidiaName =
    config.hardware.nvidia.package.name or "";
in
{
  system.nixos.tags = [
    "caninana703"
    "bore-lto"
    "xu-native"
    "nvidia5957105"
    "open"
    "non-aggressive"
  ];

  boot.kernelPackages = lib.mkForce selectedKernelPackages;

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.nvidia = {
    modesetting.enable = true;
    nvidiaSettings = true;

    # 703 alvo: NVIDIA open 595.71.05.
    # Se isto não avaliar, o módulo para antes de dry-build.
    open = lib.mkForce true;

    # Driver vem do kernelPackages do Xu, não de mkDriver manual.
    package = lib.mkForce selectedNvidia;

    powerManagement.enable = true;
    powerManagement.finegrained = false;
  };

  boot.kernelParams = [
    "nvidia-drm.modeset=1"
    "nvidia-drm.fbdev=1"
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
  ];

  boot.extraModprobeConfig = ''
    options nvidia NVreg_TemporaryFilePath=/var/tmp
  '';

  assertions = [
    {
      assertion = kernelVersion == "7.0.3";
      message = ''
        703 bore-lto abortado: kernel esperado 7.0.3.
        kernelVersion=${kernelVersion}
      '';
    }
    {
      assertion = kernelPname == "linux-cachyos-bore-lto";
      message = ''
        703 bore-lto abortado: kernel pname esperado linux-cachyos-bore-lto.
        kernelPname=${kernelPname}
      '';
    }
    {
      assertion = kernelModDirVersion == "7.0.3-cachyos-lto";
      message = ''
        703 bore-lto abortado: modDirVersion esperado 7.0.3-cachyos-lto.
        kernelModDirVersion=${kernelModDirVersion}
      '';
    }
    {
      assertion = nvidiaVersion == "595.71.05";
      message = ''
        703 bore-lto abortado: NVIDIA esperada 595.71.05.
        nvidiaVersion=${nvidiaVersion}
        nvidiaName=${nvidiaName}
      '';
    }
    {
      assertion = config.hardware.nvidia.open == true;
      message = "703 bore-lto abortado: hardware.nvidia.open precisa ser true.";
    }
    {
      assertion = !(lib.hasInfix "595.58.03" nvidiaVersion) && !(lib.hasInfix "595.58.03" nvidiaName);
      message = ''
        703 bore-lto abortado: regressao NVIDIA 595.58.03 detectada.
        nvidiaVersion=${nvidiaVersion}
        nvidiaName=${nvidiaName}
      '';
    }
    {
      assertion = !(lib.hasInfix "7.0.1" kernelVersion) && !(lib.hasInfix "701" kernelVersion);
      message = ''
        703 bore-lto abortado: caiu em 701/7.0.1.
        kernelVersion=${kernelVersion}
      '';
    }
  ];

  # Perfil não agressivo.
  zramSwap.enable = lib.mkDefault true;
  zramSwap.memoryPercent = lib.mkDefault 100;
  zramSwap.priority = lib.mkDefault 32767;

  boot.kernel.sysctl = {
    "vm.swappiness" = lib.mkForce 10;
    "vm.vfs_cache_pressure" = lib.mkForce 50;
    "vm.max_map_count" = lib.mkForce 1048576;
    "kernel.sched_autogroup_enabled" = lib.mkForce 1;
    "kernel.nmi_watchdog" = lib.mkForce 1;
  };

  environment.systemPackages = with pkgs; [
    nvtopPackages.nvidia
    vulkan-tools
    mesa-demos
  ];

  environment.etc."mocha-kde/caninana-703-bore-lto-xu-native-nvidia5957105-open.txt".text = ''
    profile=caninana-703-bore-lto-xu-native-nvidia5957105-open
    kernel_attr=pkgs.cachyosKernels."linuxPackages-cachyos-bore-lto"
    kernel_pname=${kernelPname}
    kernel_version=${kernelVersion}
    kernel_modDirVersion=${kernelModDirVersion}
    nvidia_source=selectedKernelPackages.nvidiaPackages.latest_or_production_or_stable
    nvidia_version=${nvidiaVersion}
    nvidia_name=${nvidiaName}
    nvidia_open=true
    rule=xu-native
    rule=no-mkDriver-manual
    forbidden_kernel=7.0.1
    forbidden_driver=595.58.03
    aggression=non-aggressive
  '';
}
