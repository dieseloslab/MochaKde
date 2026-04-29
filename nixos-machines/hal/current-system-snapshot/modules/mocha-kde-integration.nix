# /etc/nixos/modules/mocha-kde-integration.nix
#
# Diesel OS Lab / Mocha KDE
# Integração correta para sessão Plasma:
# - Dolphin como gerenciador de arquivos principal
# - xdg-desktop-portal-kde como portal principal
# - gtk portal apenas como fallback
# - Papirus + papirus-folders para fugir dos ícones/pastas azuis

{ pkgs, lib, ... }:

{
  environment.systemPackages =
    (with pkgs; [
      kdePackages.dolphin
      kdePackages.xdg-desktop-portal-kde

      xdg-desktop-portal
      xdg-desktop-portal-gtk

      papirus-icon-theme
    ])
    ++ lib.optional (builtins.hasAttr "papirus-folders" pkgs) pkgs."papirus-folders";

  xdg.portal = {
    enable = true;

    extraPortals = [
      pkgs.kdePackages.xdg-desktop-portal-kde
      pkgs.xdg-desktop-portal-gtk
    ];

    config = {
      common = {
        default = [ "kde" "gtk" ];
      };

      kde = {
        default = [ "kde" "gtk" ];
      };
    };
  };
}
