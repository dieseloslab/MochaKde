# /etc/nixos/modules/mocha-vm-managers.nix
#
# Diesel OS Lab - GNOME Mocha Edition
#
# Stack oficial de virtualizacao desktop:
# - GNOME Boxes
# - Virtual Machine Manager
# - libvirt/KVM
# - QEMU
# - SPICE
# - TPM virtual
# - base osinfo para deteccao correta de ISOs

{ config, lib, pkgs, ... }:

{
  programs.dconf.enable = true;

  virtualisation.libvirtd = {
    enable = true;

    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = false;
      swtpm.enable = true;
    };
  };

  programs.virt-manager.enable = true;

  virtualisation.spiceUSBRedirection.enable = true;
  services.spice-vdagentd.enable = true;

  security.polkit.enable = true;

  environment.systemPackages = with pkgs; [
    gnome-boxes
    virt-manager
    virt-viewer

    qemu_kvm
    libvirt
    spice-gtk
    spice-vdagent
    swtpm

    libosinfo
    osinfo-db
    osinfo-db-tools
  ];
}
