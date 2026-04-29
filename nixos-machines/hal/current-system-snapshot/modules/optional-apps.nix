# /etc/nixos/modules/optional-apps.nix
#
# Diesel OS Lab - GNOME Mocha Edition
#
# Este arquivo é gerenciado pelo Mocha App Picker.
# Programas opcionais escolhidos pelo usuário após a instalação.
#
# VMware removido temporariamente da configuração ativa para não puxar
# vmware-modules-workstation durante os testes com kernel Zen 7.0.2.
#
# Virtualização atual recomendada:
# - Virt Manager
# - QEMU/KVM
# - libvirt
# - SPICE
# - swtpm para suporte a TPM virtual

{ pkgs, lib, options, ... }:

let
  hasTeamViewerService = options.services ? teamviewer;
  hasAnyDeskService = options.services ? anydesk;
in
lib.mkMerge [
  {
    environment.systemPackages = with pkgs; [
      anydesk
      gparted
      protonplus
      teamviewer

      virt-manager
      qemu
      virt-viewer
      spice
      spice-gtk
      swtpm
    ];
  }

  {
    virtualisation.libvirtd.enable = true;
    virtualisation.spiceUSBRedirection.enable = true;

    users.users.hal.extraGroups = [
      "libvirtd"
      "kvm"
    ];
  }

  (lib.optionalAttrs hasAnyDeskService {
    services.anydesk.enable = true;
  })

  (lib.optionalAttrs hasTeamViewerService {
    services.teamviewer.enable = true;
  })
]
