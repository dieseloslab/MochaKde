# /etc/nixos/modules/mocha-vm-alternatives.nix
#
# Diesel OS Lab - GNOME Mocha Edition
#
# Alternativas ao GNOME Boxes:
# - Oracle VirtualBox
# - VMware Workstation
#
# Mantemos virt-manager/libvirt em outro módulo.
# Este módulo adiciona hipervisores alternativos para teste real.

{ config, lib, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  # VirtualBox desligado:
  # VirtualBox 7.2.6 nao compila vboxdrv contra Linux 6.19.x neste momento.
  virtualisation.virtualbox.host.enable = false;

  # VMware Workstation host
  virtualisation.vmware.host = {
    enable = true;

    extraPackages = with pkgs; [
      ntfs3g
    ];
  };

  # Recomendação do próprio módulo VMware do Nixpkgs:
  # evita comportamento ruim do vmware-vmx com Transparent Hugepages.
  boot.kernelParams = lib.mkAfter [
    "transparent_hugepage=never"
  ];

  # Grupos necessários para os hipervisores.
  users.users.hal.extraGroups = lib.mkAfter [
    "vboxusers"
    "libvirtd"
    "kvm"
  ];
}
