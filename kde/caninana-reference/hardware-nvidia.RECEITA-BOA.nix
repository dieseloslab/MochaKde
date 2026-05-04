# /etc/nixos/modules/hardware-nvidia.nix
#
# Diesel OS Lab - GNOME Mocha Edition
# NVIDIA 595.71.05 pinado para kernel Zen 7.0.2.

{ config, lib, ... }:

{
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    open = true;
    nvidiaSettings = true;
    powerManagement.enable = true;

    package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
      version = "595.71.05";

      sha256_64bit = "sha256-NiA7iWC35JyKQva6H1hjzeNKBek9KyS3mK8G3YRva4I=";
      sha256_aarch64 = lib.fakeHash;
      openSha256 = "sha256-Lfz71QWKM6x/jD2B22SWpUi7/og30HRlXg1kL3EWzEw=";
      settingsSha256 = "sha256-mXnf3jyvznfB3OfKd657rxv0rYHQb/dX/Riw/+N9EKU=";
      persistencedSha256 = "sha256-6CGwMd+Zc2kZNkMVUBpin1/P4/c3Mz1PaC8EzF2yjfc=";
    };
  };

  boot.extraModprobeConfig = ''
    options nvidia NVreg_TemporaryFilePath=/var/tmp
  '';
}
