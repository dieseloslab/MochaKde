# /etc/nixos/modules/kernel-cachycomp.nix
#
# Diesel OS Lab / CachyComp
#
# Objetivo:
#   testar no Mocha o kernel CachyOS equivalente ao que foi sentido como
#   mais responsivo no CachyOS, preservando fallback pelo bootloader.
#
# Importante:
#   este modulo substitui modules/test-channel-zen-nvidia.nix.
#   O driver NVIDIA 595.71.05 continua vindo de modules/hardware-nvidia.nix.

{ lib, pkgs, nix-cachyos-kernel, ... }:

{
  # Expõe pkgs.cachyosKernels.*.
  # Usamos pinned para maximizar chance de usar cache binario
  # e evitar recompilar o kernel inteiro localmente.
  nixpkgs.overlays = [
    nix-cachyos-kernel.overlays.pinned
  ];

  # Cache do mantenedor do nix-cachyos-kernel e cache Garnix.
  # Também vamos passar estes caches no NIX_CONFIG do build atual,
  # porque o daemon ainda não conhece esta configuração antes do primeiro boot.
  nix.settings.substituters = [
    "https://attic.xuyh0120.win/lantian"
    "https://cache.garnix.io"
  ];

  nix.settings.trusted-public-keys = [
    "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
    "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
  ];

  # Primeiro teste: kernel CachyOS default/latest.
  #
  # Nao usamos latest ainda porque o Cachy instalado mostrou uname
  # como linux-cachyos, nao linux-cachyos-lto. Depois que este passar,
  # testamos latest como segunda rodada.
  # Mocha Caninana Experimental:
  # Perfil experimental de kernel do Mocha para responsividade/jogos.
  # Implementacao atual: pacote upstream CachyOS via nix-cachyos-kernel,
  # integrado e validado no Mocha/NixOS com NVIDIA, tuned e stack GNOME/gaming.
  # Nao declarar como kernel autoral do Mocha enquanto depender diretamente deste pacote.
  boot.kernelPackages =
    lib.mkOverride 30 pkgs.cachyosKernels.linuxPackages-cachyos-latest;

  # Durante o teste CachyComp, desativa a specialisation mocha-lts-fallback.
  # Motivo: ela puxa linuxPackages_6_12 e mistura módulos 6.12.83 com
  # o kernel 7.0.1-cachyos.
  #
  # O fallback seguro continua existindo pela geração anterior no bootloader.
  specialisation = lib.mkForce { };
}
