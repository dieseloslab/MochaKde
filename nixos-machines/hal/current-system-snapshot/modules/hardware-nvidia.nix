# /etc/nixos/modules/hardware-nvidia.nix

{ config, ... }:

{
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    open = true;
    nvidiaSettings = true;
    powerManagement.enable = true;
    package = config.boot.kernelPackages.nvidiaPackages.production;
  };

  boot.extraModprobeConfig = ''
    options nvidia NVreg_TemporaryFilePath=/var/tmp
  '';
}
