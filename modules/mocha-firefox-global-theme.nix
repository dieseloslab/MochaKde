{ config, lib, pkgs, ... }:

{
  # MochaKde Firefox visual layer.
  #
  # Firefox Release rejeita tema XPI local unsigned.
  # Este módulo NÃO força mais o XPI local por ExtensionSettings.
  # Para a distro final, assinar/publicar o tema Mocha Firefox e só então
  # forçar por policy.

  programs.firefox = {
    enable = true;

    policies = {
      DisableAppUpdate = true;

      Preferences = {
        "toolkit.legacyUserProfileCustomizations.stylesheets" = {
          Value = true;
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
  };

  environment.etc."mocha/firefox-theme-mocha-caramelo-source/manifest.json".source =
    /etc/nixos/mocha-assets/firefox-theme-mocha-caramelo-source/manifest.json;
}
