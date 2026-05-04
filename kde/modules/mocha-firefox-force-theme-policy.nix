{ pkgs, lib, options, ... }:

let
  hasOpt = path: lib.hasAttrByPath path options;

  firefoxAppId = "{ec8030f7-c20a-464f-9b0e-13a3a9e97384}";
  firefoxThemeId = "mocha-kde-firefox-theme@dieseloslab.org";

  mochaFirefoxThemeXpi = pkgs.runCommand "mocha-kde-firefox-theme.xpi" {
    nativeBuildInputs = [ pkgs.zip ];
  } ''
    mkdir -p src

    cat > src/manifest.json <<'EOF_JSON'
{
  "manifest_version": 2,
  "name": "Mocha KDE",
  "version": "1.0.3",
  "description": "Diesel OS Lab Mocha KDE default Firefox theme",
  "browser_specific_settings": {
    "gecko": {
      "id": "mocha-kde-firefox-theme@dieseloslab.org",
      "strict_min_version": "91.0"
    }
  },
  "theme": {
    "colors": {
      "frame": "#34221b",
      "frame_inactive": "#2c1d18",
      "tab_background_text": "#faecdc",
      "tab_loading": "#d88e52",
      "tab_selected": "#4b3024",
      "tab_line": "#d88e52",
      "toolbar": "#3d261d",
      "toolbar_text": "#faecdc",
      "toolbar_field": "#4b3024",
      "toolbar_field_text": "#faecdc",
      "toolbar_field_border": "#8a5a3f",
      "toolbar_field_focus": "#5a392a",
      "toolbar_field_text_focus": "#fff0dd",
      "bookmark_text": "#faecdc",
      "button_background_hover": "#5a392a",
      "button_background_active": "#d88e52",
      "popup": "#3d261d",
      "popup_text": "#faecdc",
      "popup_border": "#8a5a3f",
      "popup_highlight": "#d88e52",
      "popup_highlight_text": "#2a1710",
      "sidebar": "#34221b",
      "sidebar_text": "#faecdc",
      "sidebar_border": "#8a5a3f",
      "ntp_background": "#34221b",
      "ntp_text": "#faecdc"
    }
  }
}
EOF_JSON

    cd src
    zip -X -r "$out" manifest.json >/dev/null
  '';

  mochaPoliciesJson = pkgs.writeText "mocha-firefox-policies.json" ''
{
  "policies": {
    "DisableAppUpdate": true,
    "ExtensionSettings": {
      "mocha-kde-firefox-theme@dieseloslab.org": {
        "installation_mode": "force_installed",
        "install_url": "file:///etc/firefox/mocha-kde-firefox-theme.xpi"
      }
    },
    "Preferences": {
      "extensions.activeThemeID": {
        "Value": "mocha-kde-firefox-theme@dieseloslab.org",
        "Status": "locked"
      },
      "browser.theme.content-theme": {
        "Value": 0,
        "Status": "locked"
      },
      "browser.theme.toolbar-theme": {
        "Value": 0,
        "Status": "locked"
      },
      "ui.systemUsesDarkTheme": {
        "Value": 1,
        "Status": "locked"
      }
    }
  }
}
  '';

  mochaFirefoxThemePackage = pkgs.runCommand "mocha-kde-firefox-theme-system-files" {} ''
    mkdir -p "$out/share/mozilla/extensions/${firefoxAppId}"
    cp ${mochaFirefoxThemeXpi} "$out/share/mozilla/extensions/${firefoxAppId}/${firefoxThemeId}.xpi"
  '';
in {
  config = lib.mkMerge [
    {
      environment.systemPackages = [
        mochaFirefoxThemePackage
      ];

      # Arquivo legível direto em /etc para auditoria e about:policies.
      environment.etc."firefox/policies/policies.json".source = lib.mkForce mochaPoliciesJson;
      environment.etc."firefox/mocha-kde-firefox-theme.xpi".source = lib.mkForce mochaFirefoxThemeXpi;
    }

    (lib.optionalAttrs (hasOpt [ "programs" "firefox" "policies" ]) {
      programs.firefox.policies = lib.mkForce {
        DisableAppUpdate = true;

        ExtensionSettings = {
          "mocha-kde-firefox-theme@dieseloslab.org" = {
            installation_mode = "force_installed";
            install_url = "file:///etc/firefox/mocha-kde-firefox-theme.xpi";
          };
        };

        Preferences = {
          "extensions.activeThemeID" = {
            Value = "mocha-kde-firefox-theme@dieseloslab.org";
            Status = "locked";
          };

          "browser.theme.content-theme" = {
            Value = 0;
            Status = "locked";
          };

          "browser.theme.toolbar-theme" = {
            Value = 0;
            Status = "locked";
          };

          "ui.systemUsesDarkTheme" = {
            Value = 1;
            Status = "locked";
          };
        };
      };
    })

    (lib.optionalAttrs (hasOpt [ "programs" "firefox" "preferences" ]) {
      programs.firefox.preferences = lib.mkForce {
        "extensions.activeThemeID" = firefoxThemeId;
        "browser.theme.content-theme" = 0;
        "browser.theme.toolbar-theme" = 0;
        "ui.systemUsesDarkTheme" = 1;
      };
    })
  ];
}
