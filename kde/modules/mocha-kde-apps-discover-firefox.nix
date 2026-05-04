{ lib, pkgs, options, ... }:

let
  hasOpt = path: lib.hasAttrByPath path options;
  pkgPath = path: lib.attrByPath path null pkgs;
  optPkg = path:
    let p = pkgPath path;
    in lib.optional (p != null) p;
in
lib.mkMerge [
  {
    environment.systemPackages =
      builtins.concatLists (map optPkg [
        [ "firefox" ]
        [ "flatpak" ]
        [ "packagekit" ]
        [ "appstream" ]
        [ "fwupd" ]
        [ "kdePackages" "discover" ]
        [ "kdePackages" "flatpak-kcm" ]
        [ "kdePackages" "packagekit-qt" ]
        [ "kdePackages" "plasma-disks" ]
        [ "kdePackages" "kio-extras" ]
        [ "kdePackages" "xdg-desktop-portal-kde" ]
      ]);

    environment.sessionVariables = {
      MOZ_ENABLE_WAYLAND = "1";
      NIXOS_OZONE_WL = "1";
      BROWSER = "firefox";
    };
  }

  (lib.mkIf (hasOpt [ "programs" "firefox" "enable" ]) {
    programs.firefox.enable = true;
  })

  (lib.mkIf (hasOpt [ "programs" "firefox" "package" ]) {
    programs.firefox.package = pkgs.firefox;
  })

  (lib.mkIf (hasOpt [ "programs" "firefox" "policies" ]) {
    programs.firefox.policies = {
      Preferences = {
        "browser.startup.page" = {
          Value = 3;
          Status = "default";
        };
        "browser.sessionstore.resume_from_crash" = {
          Value = true;
          Status = "default";
        };
      };
    };
  })

  (lib.mkIf (hasOpt [ "services" "flatpak" "enable" ]) {
    services.flatpak.enable = true;
  })

  (lib.mkIf (hasOpt [ "services" "packagekit" "enable" ]) {
    services.packagekit.enable = true;
  })

  (lib.mkIf (hasOpt [ "services" "fwupd" "enable" ]) {
    services.fwupd.enable = true;
  })

  (lib.mkIf (hasOpt [ "xdg" "portal" "enable" ]) {
    xdg.portal.enable = true;
  })

  (lib.mkIf ((hasOpt [ "xdg" "portal" "extraPortals" ]) && (pkgPath [ "kdePackages" "xdg-desktop-portal-kde" ] != null)) {
    xdg.portal.extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
  })

  (lib.mkIf ((hasOpt [ "system" "activationScripts" ]) && (pkgPath [ "flatpak" ] != null)) {
    system.activationScripts.mochaFlatpakFlathub = ''
      ${pkgs.flatpak}/bin/flatpak remote-add --system --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo >/dev/null 2>&1 || true
    '';
  })
]
