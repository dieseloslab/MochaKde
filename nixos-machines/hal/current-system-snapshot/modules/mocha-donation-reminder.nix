# /etc/nixos/modules/mocha-donation-reminder.nix
#
# Diesel OS Lab - GNOME Mocha Edition
#
# Monthly donation reminder.
# GTK4/libadwaita via GJS.
#
# Rules:
# - show automatically every 30 days
# - do not open PayPal automatically
# - no "do not show again" option
# - manual launcher is available in the app grid

{ pkgs, ... }:

let
  mochaDonationReminder = pkgs.stdenvNoCC.mkDerivation {
    pname = "mocha-donation-reminder";
    version = "0.1.0";

    src = ../apps/mocha-donation-reminder;

    dontConfigure = true;
    dontBuild = true;

    nativeBuildInputs = [
      pkgs.makeWrapper
      pkgs.wrapGAppsHook4
    ];

    buildInputs = [
      pkgs.gjs
      pkgs.gtk4
      pkgs.libadwaita
    ];

    installPhase = ''
      runHook preInstall

      install -Dm644 main.js \
        "$out/share/mocha-donation-reminder/main.js"

      makeWrapper ${pkgs.gjs}/bin/gjs "$out/bin/mocha-donation-reminder" \
        --add-flags "$out/share/mocha-donation-reminder/main.js"

      runHook postInstall
    '';
  };

  mochaDonationReminderDesktop = pkgs.makeDesktopItem {
    name = "mocha-donation-reminder";
    desktopName = "Apoiar o Diesel OS Lab";
    genericName = "Doações";
    comment = "Abra o lembrete de doações do Diesel OS Lab - GNOME Mocha Edition";
    exec = "mocha-donation-reminder --force";
    icon = "diesel-os-lab";
    terminal = false;
    categories = [
      "Utility"
    ];
  };

  mochaDonationReminderAutostartDesktop = pkgs.makeDesktopItem {
    name = "mocha-donation-reminder-autostart";
    desktopName = "Mocha Donation Reminder";
    genericName = "Doações";
    comment = "Mostra o lembrete mensal de doações do Diesel OS Lab";
    exec = "mocha-donation-reminder";
    icon = "diesel-os-lab";
    terminal = false;
    categories = [
      "Utility"
    ];
  };
in
{
  environment.systemPackages = [
    mochaDonationReminder
    mochaDonationReminderDesktop
  ];

  environment.etc."xdg/autostart/mocha-donation-reminder.desktop".source =
    "${mochaDonationReminderAutostartDesktop}/share/applications/mocha-donation-reminder-autostart.desktop";
}
