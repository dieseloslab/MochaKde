# /etc/nixos/modules/mocha-welcome.nix
#
# Diesel OS Lab - GNOME Mocha Edition
#
# Public first boot assistant.
# Rust + GTK4/libadwaita.
#
# This is the public welcome/first-boot app.
# It must not depend on:
# - personal GitHub account
# - Mocca Edition SSH key
# - MOCHAFAST
# - private developer backup

{ pkgs, lib, ... }:

let
  mochaWelcome = pkgs.rustPlatform.buildRustPackage {
    pname = "mocha-welcome";
    version = "0.1.0";

    src = ../apps/mocha-welcome;

    cargoHash = "sha256-gJ0AVkApMmyR5nw25/1ARXneVyzgJf5oHu/Q/VO/bgQ=";

    nativeBuildInputs = [
      pkgs.pkg-config
      pkgs.wrapGAppsHook4
    ];

    buildInputs = [
      pkgs.gtk4
      pkgs.libadwaita
    ];
  };

  mochaWelcomeIcon = pkgs.runCommand "mocha-welcome-icon" { } ''
    install -Dm644 \
      ${../assets/branding/welcome/mocha-welcome.svg} \
      $out/share/icons/hicolor/scalable/apps/mocha-welcome.svg

    install -Dm644 \
      ${../assets/branding/welcome/mocha-welcome.svg} \
      $out/share/pixmaps/mocha-welcome.svg
  '';


  mochaBrandingAssets = pkgs.runCommand "mocha-branding-assets" { } ''
    install -Dm644 \
      ${../assets/branding/logo/diesel-os-lab-icon.png} \
      $out/share/diesel-os-lab/branding/logo/diesel-os-lab-icon.png
  '';

  mochaWelcomeDesktop = pkgs.makeDesktopItem {
    name = "mocha-welcome";
    desktopName = "Mocha Welcome";
    genericName = "First Boot Assistant";
    comment = "First boot assistant for Diesel OS Lab - GNOME Mocha Edition";
    exec = "mocha-welcome";
    icon = "mocha-welcome";
    terminal = false;
    categories = [
      "System"
      "Settings"
    ];
  };

  mochaWelcomeAutostart = pkgs.writeShellScriptBin "mocha-welcome-autostart" ''
    if [ -f /var/lib/mocha-first-boot/public-first-boot.done ]; then
      exit 0
    fi

    exec ${mochaWelcome}/bin/mocha-welcome
  '';

  mochaWelcomeAutostartDesktop = pkgs.makeDesktopItem {
    name = "mocha-welcome-autostart";
    desktopName = "Mocha Welcome";
    genericName = "First Boot Assistant";
    comment = "Start Mocha Welcome on first login";
    exec = "mocha-welcome-autostart";
    icon = "mocha-welcome";
    terminal = false;
    categories = [
      "System"
      "Settings"
    ];
  };
in
{
  environment.systemPackages = [
    mochaWelcome
    mochaWelcomeIcon
    mochaBrandingAssets
    mochaWelcomeDesktop
    mochaWelcomeAutostart
  ];

  environment.etc."xdg/autostart/mocha-welcome.desktop".source =
    "${mochaWelcomeAutostartDesktop}/share/applications/mocha-welcome-autostart.desktop";
}
