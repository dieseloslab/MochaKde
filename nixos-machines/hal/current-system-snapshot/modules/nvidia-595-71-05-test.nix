# /etc/nixos/modules/nvidia-595-71-05-test.nix
#
# Diesel OS Lab - GNOME Mocha Edition
# Teste temporario do NVIDIA Linux 595.71.05.
#
# Remover este modulo quando o nixpkgs trouxer oficialmente o 595.71.05.

{ config, lib, ... }:

{
  hardware.nvidia.open = lib.mkForce true;

  hardware.nvidia.package = lib.mkForce (
    config.boot.kernelPackages.nvidiaPackages.mkDriver {
      version = "595.71.05";

      sha256_64bit = "sha256-NiA7iWC35JyKQva6H1hjzeNKBek9KyS3mK8G3YRva4I=";

      # Ignorado em x86_64. Mantido fake apenas para satisfazer a assinatura do mkDriver.
      sha256_aarch64 = lib.fakeHash;

      openSha256 = "sha256-Lfz71QWKM6x/jD2B22SWpUi7/og30HRlXg1kL3EWzEw=";
      settingsSha256 = "sha256-mXnf3jyvznfB3OfKd657rxv0rYHQb/dX/Riw/+N9EKU=";
      persistencedSha256 = "sha256-Z/6IvEEa/XfZ5F5qoSIPvXJLGtscYVqjFxHZaN/M2Ts=";
    }
  );
}
