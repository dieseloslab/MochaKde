# /etc/nixos/modules/mocha-kde.nix
#
# Diesel OS Lab / Mocha KDE
#
# Fase 1:
# - Instala KDE Plasma 6
# - Usa SDDM como login manager
# - Mantem GNOME instalado para rollback/teste
# - Adiciona pacote visual Mocha KDE
# - Cria comando mocha-kde-theme para aplicar aparência escura/mocha

{ config, pkgs, lib, ... }:

let
  optionalPkgs = set: names:
    builtins.concatLists (
      map
        (name:
          lib.optionals (builtins.hasAttr name set) [
            (builtins.getAttr name set)
          ])
        names
    );

  kdeBase = optionalPkgs pkgs.kdePackages [
    "ark"
    "dolphin"
    "filelight"
    "gwenview"
    "kate"
    "kcalc"
    "kdeconnect-kde"
    "konsole"
    "okular"
    "plasma-systemmonitor"
    "spectacle"
  ];

  mochaExtras = optionalPkgs pkgs [
    "bibata-cursors"
    "fastfetch"
    "fluent-icon-theme"
    "papirus-icon-theme"
    "wl-clipboard"
    "xdg-utils"
  ];

  mochaKdeTheme = pkgs.writeShellScriptBin "mocha-kde-theme" ''
    set -u

    echo "===== APLICANDO TEMA MOCHA KDE NO USUARIO: $USER ====="

    if command -v lookandfeeltool >/dev/null 2>&1; then
      lookandfeeltool -a org.kde.breezedark.desktop || true
    fi

    if command -v plasma-apply-colorscheme >/dev/null 2>&1; then
      plasma-apply-colorscheme BreezeDark || true
    fi

    if command -v kwriteconfig6 >/dev/null 2>&1; then
      kwriteconfig6 --file kdeglobals --group General --key ColorScheme BreezeDark || true
      kwriteconfig6 --file kdeglobals --group General --key accentColor "166,124,82" || true

      # Comportamento mais parecido com Windows: duplo clique para abrir.
      kwriteconfig6 --file kdeglobals --group KDE --key SingleClick false || true

      # Icones/cursor, se os pacotes existirem.
      kwriteconfig6 --file kdeglobals --group Icons --key Theme Papirus-Dark || true
      kwriteconfig6 --file kcminputrc --group Mouse --key cursorTheme Bibata-Modern-Classic || true

      # KWin: visual limpo, blur e menos sensação de atraso.
      kwriteconfig6 --file kwinrc --group Plugins --key blurEnabled true || true
      kwriteconfig6 --file kwinrc --group Windows --key Placement Smart || true
      kwriteconfig6 --file kwinrc --group Compositing --key LatencyPolicy Low || true
      kwriteconfig6 --file kwinrc --group Compositing --key AnimationSpeed 2 || true

      # Tema Plasma padrão escuro.
      kwriteconfig6 --file plasmarc --group Theme --key name default || true

      # Tela de bloqueio mais limpa.
      kwriteconfig6 --file kscreenlockerrc --group Greeter --group LnF --key showMediaControls false || true
    fi

    WALL="$(
      find /etc/nixos/assets /etc/nixos/modules /etc/nixos \
        -type f \
        \( -iname '*wallpaper*.jpg' -o -iname '*wallpaper*.png' -o -iname '*mocha*.jpg' -o -iname '*mocha*.png' \) \
        2>/dev/null | head -n 1 || true
    )"

    if [ -n "$WALL" ] && command -v plasma-apply-wallpaperimage >/dev/null 2>&1; then
      plasma-apply-wallpaperimage "$WALL" || true
    fi

    if command -v qdbus6 >/dev/null 2>&1; then
      qdbus6 org.kde.KWin /KWin reconfigure >/dev/null 2>&1 || true
    fi

    if command -v kquitapp6 >/dev/null 2>&1; then
      kquitapp6 plasmashell >/dev/null 2>&1 || true
      sleep 1
      if command -v kstart >/dev/null 2>&1; then
        kstart plasmashell >/dev/null 2>&1 || true
      fi
    fi

    echo "===== TEMA MOCHA KDE APLICADO ====="
    echo "Se algo nao mudar na hora, faca logout/login no Plasma."
  '';
in
{
  services.xserver.enable = true;

  services.xserver.xkb = {
    layout = "br";
    variant = "";
  };

  console.keyMap = "br-abnt2";

  # Nesta fase, mantemos os pacotes GNOME disponíveis,
  # mas trocamos o login manager para SDDM, que combina melhor com KDE.
  services.displayManager.gdm.enable = lib.mkForce false;

  services.displayManager.sddm = {
    enable = true;

    # Plasma 6 define SDDM Wayland por padrão no nixpkgs atual.
    # Para a primeira fase do Mocha KDE com NVIDIA, forçamos SDDM em X11.
    # A sessão Plasma Wayland ainda pode aparecer como opção no login.
    wayland.enable = lib.mkForce false;

    theme = lib.mkDefault "breeze";
  };

  services.desktopManager.plasma6.enable = true;

  # Como estamos testando KDE por cima de uma base GNOME,
  # o Plasma e o Seahorse tentam definir SSH_ASKPASS ao mesmo tempo.
  # Para o Mocha KDE, forçamos o askpass do KDE.
  programs.ssh.askPassword = lib.mkForce "${pkgs.kdePackages.ksshaskpass}/bin/ksshaskpass";

  environment.systemPackages = kdeBase ++ mochaExtras ++ [
    mochaKdeTheme
  ];

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };
}
