# /etc/nixos/modules/local-gnome-extensions.nix

{ pkgs, ... }:

let
  localExtRoot = "/etc/nixos/assets/gnome-shell-extensions";
  tunedUuid = "tuned-switcher@rea1-ms";
  powerOffUuid = "power-off-options@axelitama.github.io";
  dashToDockUuid = "dash-to-dock@micxgx.gmail.com";
in
{
  system.activationScripts.localGnomeExtensions = {
    text = ''
      install_ext() {
        local uuid="$1"

        if [ -d "${localExtRoot}/$uuid" ]; then
          install -d -m 0755 -o hal -g users /home/hal/.local/share/gnome-shell/extensions
          rm -rf "/home/hal/.local/share/gnome-shell/extensions/$uuid"
          cp -a "${localExtRoot}/$uuid" /home/hal/.local/share/gnome-shell/extensions/
          chown -R hal:users "/home/hal/.local/share/gnome-shell/extensions/$uuid"
          chmod -R u+rwX "/home/hal/.local/share/gnome-shell/extensions/$uuid"

          if [ -d "/home/hal/.local/share/gnome-shell/extensions/$uuid/schemas" ]; then
            ${pkgs.glib.dev}/bin/glib-compile-schemas "/home/hal/.local/share/gnome-shell/extensions/$uuid/schemas" || true
          fi
        fi
      }

      install_ext "${tunedUuid}"
      install_ext "${powerOffUuid}"
      install_ext "${dashToDockUuid}"
    '';
  };

  systemd.user.services.mocha-enable-local-gnome-extensions = {
    description = "Enable local GNOME extensions used by Mocha";
    wantedBy = [ "graphical-session.target" ];
    after = [ "graphical-session-pre.target" ];
    partOf = [ "graphical-session.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
      for uuid in ${tunedUuid} ${powerOffUuid} ${dashToDockUuid}; do
        if [ -d "$HOME/.local/share/gnome-shell/extensions/$uuid" ]; then
          ${pkgs.gnome-shell}/bin/gnome-extensions enable "$uuid" || true
        fi
      done
    '';
  };
}
