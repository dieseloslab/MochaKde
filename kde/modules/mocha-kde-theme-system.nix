{ pkgs, lib, ... }:

let
  mochaThemePackage = pkgs.runCommand "mocha-kde-theme-system" {} ''
    mkdir -p "$out/share/color-schemes"
    mkdir -p "$out/share/plasma/desktoptheme/MochaKde"
    mkdir -p "$out/share/konsole"

    cat > "$out/share/color-schemes/MochaKde.colors" <<'EOF_COLORS'
[ColorEffects:Disabled]
Color=92,74,62
ColorAmount=0.45
ColorEffect=0
ContrastAmount=0.65
ContrastEffect=1
IntensityAmount=0.10
IntensityEffect=2

[ColorEffects:Inactive]
ChangeSelectionColor=true
Color=126,92,70
ColorAmount=0.10
ColorEffect=2
ContrastAmount=0.10
ContrastEffect=2
Enable=false
IntensityAmount=0.00
IntensityEffect=0

[Colors:Button]
BackgroundAlternate=72,45,33
BackgroundNormal=61,38,29
DecorationFocus=218,142,82
DecorationHover=236,159,95
ForegroundActive=244,171,103
ForegroundInactive=190,165,145
ForegroundLink=230,154,91
ForegroundNegative=238,95,91
ForegroundNeutral=221,170,91
ForegroundNormal=250,236,220
ForegroundPositive=127,185,128
ForegroundVisited=190,130,90

[Colors:Complementary]
BackgroundAlternate=62,39,30
BackgroundNormal=48,31,25
DecorationFocus=218,142,82
DecorationHover=236,159,95
ForegroundActive=244,171,103
ForegroundInactive=190,165,145
ForegroundLink=230,154,91
ForegroundNegative=238,95,91
ForegroundNeutral=221,170,91
ForegroundNormal=250,236,220
ForegroundPositive=127,185,128
ForegroundVisited=190,130,90

[Colors:Selection]
BackgroundAlternate=188,111,65
BackgroundNormal=216,142,82
DecorationFocus=244,171,103
DecorationHover=244,171,103
ForegroundActive=255,246,235
ForegroundInactive=250,226,205
ForegroundLink=70,40,24
ForegroundNegative=70,20,18
ForegroundNeutral=80,55,25
ForegroundNormal=39,22,15
ForegroundPositive=22,65,28
ForegroundVisited=74,45,28

[Colors:Tooltip]
BackgroundAlternate=72,45,33
BackgroundNormal=56,36,28
DecorationFocus=218,142,82
DecorationHover=236,159,95
ForegroundActive=244,171,103
ForegroundInactive=190,165,145
ForegroundLink=230,154,91
ForegroundNegative=238,95,91
ForegroundNeutral=221,170,91
ForegroundNormal=250,236,220
ForegroundPositive=127,185,128
ForegroundVisited=190,130,90

[Colors:View]
BackgroundAlternate=54,35,28
BackgroundNormal=44,29,24
DecorationFocus=218,142,82
DecorationHover=236,159,95
ForegroundActive=244,171,103
ForegroundInactive=190,165,145
ForegroundLink=230,154,91
ForegroundNegative=238,95,91
ForegroundNeutral=221,170,91
ForegroundNormal=250,236,220
ForegroundPositive=127,185,128
ForegroundVisited=190,130,90

[Colors:Window]
BackgroundAlternate=67,42,32
BackgroundNormal=52,34,27
DecorationFocus=218,142,82
DecorationHover=236,159,95
ForegroundActive=244,171,103
ForegroundInactive=190,165,145
ForegroundLink=230,154,91
ForegroundNegative=238,95,91
ForegroundNeutral=221,170,91
ForegroundNormal=250,236,220
ForegroundPositive=127,185,128
ForegroundVisited=190,130,90

[General]
ColorScheme=MochaKde
Name=Mocha KDE
shadeSortColumn=true

[KDE]
contrast=4

[WM]
activeBackground=74,49,38
activeBlend=74,49,38
activeForeground=235,216,196
inactiveBackground=52,34,27
inactiveBlend=52,34,27
inactiveForeground=176,145,122
EOF_COLORS

    cp "$out/share/color-schemes/MochaKde.colors" "$out/share/plasma/desktoptheme/MochaKde/colors"

    cat > "$out/share/plasma/desktoptheme/MochaKde/metadata.json" <<'EOF_META'
{
  "KPlugin": {
    "Authors": [
      {
        "Name": "Diesel OS Lab"
      }
    ],
    "Category": "Plasma Theme",
    "Description": "Mocha KDE Plasma theme overlay",
    "Id": "MochaKde",
    "License": "GPL",
    "Name": "Mocha KDE"
  },
  "X-Plasma-API": "5.0"
}
EOF_META

    cat > "$out/share/konsole/Mocha.profile" <<'EOF_PROFILE'
[Appearance]
ColorScheme=MochaKonsole
Font=Hack,11,-1,5,50,0,0,0,0,0
AntiAliasFonts=true
UseFontLineCharacters=true

[General]
Command=/run/current-system/sw/bin/bash
Name=Mocha
Parent=FALLBACK/
TerminalColumns=120
TerminalRows=32

[Scrolling]
HistoryMode=2
HistorySize=10000

[Terminal Features]
BlinkingCursorEnabled=false
EOF_PROFILE

    cat > "$out/share/konsole/MochaKonsole.colorscheme" <<'EOF_KONSOLE'
[Background]
Color=66,43,34

[BackgroundFaint]
Color=56,36,29

[BackgroundIntense]
Color=82,54,41

[Foreground]
Color=206,174,145

[ForegroundFaint]
Color=166,134,112

[ForegroundIntense]
Color=226,198,170

[Color0]
Color=98,68,53

[Color0Faint]
Color=72,50,40

[Color0Intense]
Color=142,104,78

[Color1]
Color=218,112,98

[Color1Faint]
Color=174,82,72

[Color1Intense]
Color=242,136,120

[Color2]
Color=232,154,91

[Color2Faint]
Color=190,119,74

[Color2Intense]
Color=248,178,112

[Color3]
Color=223,183,104

[Color3Faint]
Color=184,139,78

[Color3Intense]
Color=246,204,122

[Color4]
Color=198,135,88

[Color4Faint]
Color=154,96,68

[Color4Intense]
Color=228,158,104

[Color5]
Color=188,126,88

[Color5Faint]
Color=148,92,68

[Color5Intense]
Color=220,148,100

[Color6]
Color=190,160,136

[Color6Faint]
Color=154,124,104

[Color6Intense]
Color=220,186,158

[Color7]
Color=206,174,145

[Color7Faint]
Color=166,134,112

[Color7Intense]
Color=226,198,170

[General]
Description=MochaKonsole
Opacity=1
Wallpaper=

[Highlight]
Color=216,142,82

[HighlightForeground]
Color=48,28,19
EOF_KONSOLE
  '';
in {
  environment.systemPackages = [
    mochaThemePackage
  ];

  environment.etc."xdg/konsolerc".text = ''
    [Desktop Entry]
    DefaultProfile=Mocha.profile

    [General]
    ConfigVersion=1

    [UiSettings]
    ColorScheme=MochaKde
  '';
}
