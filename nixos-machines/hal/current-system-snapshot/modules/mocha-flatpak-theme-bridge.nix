# /etc/nixos/modules/mocha-flatpak-theme-bridge.nix

{ pkgs, lib, ... }:

let
  themeName = "Mocha";

  # Apps Flatpak que devem respeitar a identidade visual Mocha quando suportarem GTK.
  mochaFlatpakApps = [
    "org.gnome.Evolution"
  ];

  mochaFlatpakThemeBridge = pkgs.writeShellScriptBin "mocha-flatpak-theme-bridge" ''
    set -eu

    export PATH="${pkgs.flatpak}/bin:${pkgs.coreutils}/bin:${pkgs.gnugrep}/bin:${pkgs.findutils}/bin:$PATH"

    if ! command -v flatpak >/dev/null 2>&1; then
      exit 0
    fi

    for app in ${lib.escapeShellArgs mochaFlatpakApps}; do
      if flatpak info "$app" >/dev/null 2>&1; then
        flatpak override --user \
          --env=GTK_THEME=${themeName} \
          --filesystem="$HOME/.themes:ro" \
          --filesystem="$HOME/.local/share/themes:ro" \
          --filesystem="$HOME/.config/gtk-3.0:ro" \
          --filesystem="$HOME/.config/gtk-4.0:ro" \
          "$app"
      fi
    done
  '';
in
{
  environment.systemPackages = [
    mochaFlatpakThemeBridge
  ];

  systemd.user.services.mocha-flatpak-theme-bridge = {
    description = "Apply Diesel OS Lab Mocha theme bridge to compatible Flatpak applications";
    wantedBy = [ "default.target" ];
    after = [ "graphical-session-pre.target" ];

    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${mochaFlatpakThemeBridge}/bin/mocha-flatpak-theme-bridge";
      RemainAfterExit = true;
    };
  };
}
