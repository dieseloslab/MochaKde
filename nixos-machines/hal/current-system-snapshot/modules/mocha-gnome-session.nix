# /etc/nixos/modules/mocha-gnome-session.nix
#
# Diesel OS Lab - Mocha
# Mantem KDE/Plasma com SDDM, mas adiciona GNOME como sessao no login.

{ pkgs, lib, ... }:

{
  # O Mocha KDE usa SDDM. Nao trocar para GDM aqui.
  services.displayManager.gdm.enable = lib.mkForce false;

  # Adiciona GNOME Shell como sessao selecionavel.
  services.desktopManager.gnome.enable = true;

  environment.systemPackages = with pkgs; [
    nautilus
    gnome-terminal
    gnome-tweaks
    gnome-extension-manager
  ];
}
