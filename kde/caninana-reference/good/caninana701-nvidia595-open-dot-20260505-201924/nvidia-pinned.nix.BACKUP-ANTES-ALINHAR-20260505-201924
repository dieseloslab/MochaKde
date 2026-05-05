{ config, lib, pkgs, ... }:

let
  nvidia595 = config.boot.kernelPackages.nvidiaPackages.mkDriver {
    version = "595.71.05";

    sha256_64bit = "sha256-NiA7iWC35JyKQva6H1hjzeNKBek9KyS3mK8G3YRva4I=";
    sha256_aarch64 = "sha256-XzKloS00dFKTd4ATWkTIhm9eG/OzR/Sim6MboNZWPu8=";

    openSha256 = "sha256-Lfz71QWKM6x/jD2B22SWpUi7/og30HRlXg1kL3EWzEw=";
    settingsSha256 = "sha256-mXnf3jyvznfB3OfKd657rxv0rYHQb/dX/Riw/+N9EKU=";
    persistencedSha256 = "sha256-Z/6IvEEa/XfZ5F5qoSIPvXJLGtscYVqjFxHZaN/M2Ts=";
  };
in
{
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.nvidia = {
    modesetting.enable = true;

    # Isto já instala/expõe o painel NVIDIA correto do driver.
    # Não adicionar pkgs.nvidia-settings manualmente: esse atributo não existe
    # no nixpkgs atual avaliado pelo MochaKde.
    nvidiaSettings = true;

    package = nvidia595;

    open = false;

    powerManagement.enable = true;
    powerManagement.finegrained = false;
  };

  boot.kernelParams = [
    "nvidia-drm.modeset=1"
    "nvidia-drm.fbdev=1"
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
  ];

  assertions = [
    {
      assertion = config.hardware.nvidia.package.version == "595.71.05";
      message = ''
        MochaKde esperava NVIDIA 595.71.05, mas a versão avaliada foi:
        ${config.hardware.nvidia.package.version}
      '';
    }
  ];

  environment.systemPackages = with pkgs; [
    nvtopPackages.nvidia
    vulkan-tools
    mesa-demos
  ];
}
