# /etc/nixos/modules/mocha-app-picker-gtk.nix
#
# Diesel OS Lab - GNOME Mocha Edition
#
# Mocha App Picker GTK/libadwaita.
#
# Instalador gráfico de aplicativos opcionais do Mocha.
# Usa catálogo TOML multilíngue, backend declarativo para NixOS,
# suporte a Flatpak e opções especiais como VMware, VirtualBox,
# TeamViewer e AnyDesk.

{ pkgs, lib, ... }:

let
  mochaAppPickerGtk = pkgs.rustPlatform.buildRustPackage {
    pname = "mocha-app-picker-gtk";
    version = "0.1.0";

    src = ../apps/mocha-app-picker-gtk;

    cargoHash = "sha256-UnwFyGtWEd0PwI+FY8bBI/PgaGJ4VsJkxg2MqP2/l+U=";

    nativeBuildInputs = [
      pkgs.pkg-config
      pkgs.wrapGAppsHook4
    ];

    buildInputs = [
      pkgs.gtk4
      pkgs.libadwaita
    ];

    postInstall = ''
      mkdir -p "$out/share/mocha-app-picker-gtk"
      cp -r ${../apps/mocha-app-picker-gtk/catalog} "$out/share/mocha-app-picker-gtk/catalog"
    '';

    meta = {
      description = "GTK/libadwaita optional application installer for Diesel OS Lab - GNOME Mocha Edition";
      mainProgram = "mocha-app-picker-gtk";
    };
  };

  mochaAppPickerGtkDesktop = pkgs.makeDesktopItem {
    name = "mocha-app-picker-gtk";
    desktopName = "Mocha App Picker";
    genericName = "Optional Software Installer";
    comment = "Install and remove optional applications on Diesel OS Lab - GNOME Mocha Edition";
    exec = "mocha-app-picker-gtk";
    icon = "system-software-install";
    terminal = false;
    categories = [
      "System"
      "Settings"
    ];
  };
in
{
  environment.systemPackages = [
    mochaAppPickerGtk
    mochaAppPickerGtkDesktop
  ];
}
