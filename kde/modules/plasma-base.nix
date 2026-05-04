{ config, lib, pkgs, ... }:

{
  # Plasma/KDE base.
  # Este módulo pertence ao MochaKde.
  # NUNCA importar no Mocha GNOME ativo.

  services.xserver.enable = true;

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  services.desktopManager.plasma6.enable = true;

  xdg.portal.enable = true;

  environment.systemPackages = with pkgs; [
    kdePackages.dolphin
    kdePackages.konsole
    kdePackages.kate
    kdePackages.ark
    kdePackages.spectacle
    kdePackages.kcalc
    wl-clipboard
    xclip
    xdg-utils
  ];
}
