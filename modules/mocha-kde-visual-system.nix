{ config, lib, pkgs, ... }:

{
  # MochaKde visual system layer.
  # KDE: fornece a paleta Mocha KDE no sistema.
  # Firefox: fornece tema local da distro via políticas, sem apagar perfil e sem user.js.

  environment.etc."xdg/color-schemes/MochaKDE.colors".text = ''
    [ColorEffects:Disabled]
    Color=56,46,42
    ColorAmount=0
    ColorEffect=0
    ContrastAmount=0.65
    ContrastEffect=1
    IntensityAmount=0.10
    IntensityEffect=2

    [Colors:Selection]
    BackgroundAlternate=180,106,50
    BackgroundNormal=196,122,58
    DecorationFocus=221,153,86
    DecorationHover=230,169,102
    ForegroundActive=35,24,18
    ForegroundInactive=72,50,38
    ForegroundLink=72,43,23
    ForegroundNegative=92,31,28
    ForegroundNeutral=82,55,28
    ForegroundNormal=38,25,18
    ForegroundPositive=35,70,42
    ForegroundVisited=86,55,35

    [Colors:View]
    BackgroundAlternate=57,40,32
    BackgroundNormal=49,33,26
    DecorationFocus=196,122,58
    DecorationHover=215,143,74
    ForegroundActive=245,190,129
    ForegroundInactive=166,139,121
    ForegroundLink=230,162,91
    ForegroundNegative=239,83,80
    ForegroundNeutral=244,180,80
    ForegroundNormal=242,229,218
    ForegroundPositive=139,195,74
    ForegroundVisited=198,143,94

    [Colors:Window]
    BackgroundAlternate=65,45,36
    BackgroundNormal=56,38,30
    DecorationFocus=196,122,58
    DecorationHover=215,143,74
    ForegroundActive=245,190,129
    ForegroundInactive=166,139,121
    ForegroundLink=230,162,91
    ForegroundNegative=239,83,80
    ForegroundNeutral=244,180,80
    ForegroundNormal=242,229,218
    ForegroundPositive=139,195,74
    ForegroundVisited=198,143,94

    [Colors:Button]
    BackgroundAlternate=73,50,39
    BackgroundNormal=66,45,35
    DecorationFocus=196,122,58
    DecorationHover=215,143,74
    ForegroundActive=245,190,129
    ForegroundInactive=166,139,121
    ForegroundLink=230,162,91
    ForegroundNegative=239,83,80
    ForegroundNeutral=244,180,80
    ForegroundNormal=242,229,218
    ForegroundPositive=139,195,74
    ForegroundVisited=198,143,94

    [General]
    ColorScheme=MochaKDE
    Name=Mocha KDE
    shadeSortColumn=true

    [KDE]
    contrast=4

    [WM]
    activeBackground=56,38,30
    activeBlend=56,38,30
    activeForeground=242,229,218
    inactiveBackground=42,30,25
    inactiveBlend=42,30,25
    inactiveForeground=174,150,132
  '';

  environment.etc."mocha/firefox-theme-mocha-kde/manifest.json".source =
    /etc/nixos/mocha-assets/firefox-theme-mocha-kde/manifest.json;

  programs.firefox = {
    enable = true;

    policies = {
      ExtensionSettings = {
        "mocha-kde-firefox-theme@dieseloslab" = {
          installation_mode = "force_installed";
          install_url = "file:///etc/mocha/firefox-theme-mocha-kde/manifest.json";
        };
      };

      Preferences = {
        "extensions.activeThemeID" = {
          Value = "mocha-kde-firefox-theme@dieseloslab";
          Status = "default";
        };

        "browser.theme.content-theme" = {
          Value = 0;
          Status = "default";
        };

        "browser.theme.toolbar-theme" = {
          Value = 0;
          Status = "default";
        };
      };
    };
  };
}
