# /etc/nixos/modules/mocha-icons.nix
#
# Diesel OS Lab - Mocha
# Icones escuros para evitar visual azul padrao do KDE/GNOME.

{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    papirus-icon-theme
    fluent-icon-theme
  ];
}
