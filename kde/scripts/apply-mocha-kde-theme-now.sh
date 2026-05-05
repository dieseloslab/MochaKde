#!/usr/bin/env bash
set -euo pipefail

if [ "$(id -u)" -eq 0 ]; then
  echo "ERRO: não rode este script como root."
  exit 1
fi

DESKTOP_INFO="$(
  {
    echo "XDG_CURRENT_DESKTOP=${XDG_CURRENT_DESKTOP:-}"
    echo "DESKTOP_SESSION=${DESKTOP_SESSION:-}"
    loginctl show-session "${XDG_SESSION_ID:-self}" -p Desktop -p Type 2>/dev/null || true
  } | tr '\n' ' '
)"

if ! echo "$DESKTOP_INFO" | grep -qiE 'KDE|Plasma'; then
  echo "ERRO: sessão atual não parece KDE/Plasma."
  echo "$DESKTOP_INFO"
  echo "Não vou aplicar tema KDE fora do KDE."
  exit 1
fi

TS="$(date +%Y%m%d-%H%M%S)"
ROOT="/media/mochafast/MochaKde"
SNAP="$ROOT/kde/state/plasma-theme-before-$TS"
LOG="$SNAP/apply.log"

mkdir -p "$SNAP/config" "$SNAP/local-share" "$SNAP/runtime"

exec > >(tee -a "$LOG") 2>&1

echo "===== MOCHA KDE THEME APPLY - $TS ====="
echo "Snapshot: $SNAP"
echo

echo "===== SESSÃO ====="
echo "$DESKTOP_INFO"
echo

echo "===== SNAPSHOT DOS ARQUIVOS KDE ====="
for f in \
  kdeglobals \
  plasmarc \
  kwinrc \
  kscreenlockerrc \
  dolphinrc \
  konsolerc \
  ksmserverrc \
  plasma-org.kde.plasma.desktop-appletsrc
do
  if [ -f "$HOME/.config/$f" ]; then
    cp -a "$HOME/.config/$f" "$SNAP/config/$f"
    echo "copiado: ~/.config/$f"
  else
    echo "ausente: ~/.config/$f"
  fi
done

for d in \
  "$HOME/.local/share/color-schemes" \
  "$HOME/.local/share/plasma" \
  "$HOME/.local/share/icons" \
  "$HOME/.local/share/aurorae"
do
  if [ -e "$d" ]; then
    bn="$(basename "$d")"
    cp -a "$d" "$SNAP/local-share/$bn" 2>/dev/null || true
    echo "snapshot local-share: $d"
  fi
done

KWRITE="$(command -v kwriteconfig6 || command -v kwriteconfig5 || true)"
KREAD="$(command -v kreadconfig6 || command -v kreadconfig5 || true)"
QDBUS="$(command -v qdbus6 || command -v qdbus || true)"

if [ -z "$KWRITE" ]; then
  echo "ERRO: kwriteconfig6/5 não encontrado. Não vou editar KDE na mão."
  exit 1
fi

echo
echo "===== FERRAMENTAS ====="
echo "kwriteconfig: $KWRITE"
echo "kreadconfig:  ${KREAD:-ausente}"
echo "qdbus:        ${QDBUS:-ausente}"
echo

echo "===== CRIANDO ESQUEMA DE CORES MOCHA KDE ====="
mkdir -p "$HOME/.local/share/color-schemes"

BASE_SCHEME=""
for d in \
  "$HOME/.local/share/color-schemes" \
  "$HOME/.nix-profile/share/color-schemes" \
  "/etc/profiles/per-user/$(id -un)/share/color-schemes" \
  "/run/current-system/sw/share/color-schemes"
do
  if [ -f "$d/BreezeDark.colors" ]; then
    BASE_SCHEME="$d/BreezeDark.colors"
    break
  fi
done

if [ -n "$BASE_SCHEME" ]; then
  cp -a "$BASE_SCHEME" "$HOME/.local/share/color-schemes/MochaKDE.colors"
  sed -i \
    -e 's/^Name=.*/Name=Mocha KDE/' \
    -e 's/^ColorScheme=.*/ColorScheme=MochaKDE/' \
    "$HOME/.local/share/color-schemes/MochaKDE.colors" || true
  echo "Criado: ~/.local/share/color-schemes/MochaKDE.colors a partir de $BASE_SCHEME"
else
  echo "Aviso: BreezeDark.colors não encontrado; vou usar BreezeDark direto."
fi

echo
echo "===== ESCOLHENDO ÍCONES ====="
ICON_THEME="breeze-dark"
for t in \
  "Papirus-Dark" \
  "Papirus" \
  "Tela-circle-dracula-dark" \
  "Tela-circle-dark" \
  "breeze-dark" \
  "breeze"
do
  for d in \
    "$HOME/.local/share/icons/$t" \
    "$HOME/.nix-profile/share/icons/$t" \
    "/etc/profiles/per-user/$(id -un)/share/icons/$t" \
    "/run/current-system/sw/share/icons/$t"
  do
    if [ -d "$d" ]; then
      ICON_THEME="$t"
      break 2
    fi
  done
done
echo "Ícones escolhidos: $ICON_THEME"

echo
echo "===== APLICANDO VISUAL GLOBAL ====="

if command -v plasma-apply-lookandfeel >/dev/null 2>&1; then
  plasma-apply-lookandfeel -a org.kde.breezedark.desktop || true
fi

if command -v plasma-apply-colorscheme >/dev/null 2>&1; then
  plasma-apply-colorscheme MochaKDE || plasma-apply-colorscheme BreezeDark || true
fi

"$KWRITE" --file kdeglobals --group General --key ColorScheme "MochaKDE"
"$KWRITE" --file kdeglobals --group General --key AccentColor "156,103,73"
"$KWRITE" --file kdeglobals --group General --key accentColorFromWallpaper false
"$KWRITE" --file kdeglobals --group KDE --key LookAndFeelPackage "org.kde.breezedark.desktop"
"$KWRITE" --file kdeglobals --group KDE --key widgetStyle "Breeze"
"$KWRITE" --file kdeglobals --group Icons --key Theme "$ICON_THEME"

echo
echo "===== REDUZINDO ANIMAÇÕES / PERFIL GAMER ====="
"$KWRITE" --file kdeglobals --group KDE --key AnimationDurationFactor 0
"$KWRITE" --file kwinrc --group Compositing --key AnimationSpeed 0
"$KWRITE" --file kwinrc --group Windows --key BorderlessMaximizedWindows true

for key in \
  blurEnabled \
  contrastEnabled \
  kwin4_effect_fadeEnabled \
  kwin4_effect_fadingpopupsEnabled \
  kwin4_effect_loginEnabled \
  kwin4_effect_logoutEnabled \
  kwin4_effect_scaleEnabled \
  slidingpopupsEnabled \
  wobblywindowsEnabled
do
  "$KWRITE" --file kwinrc --group Plugins --key "$key" false
done

echo
echo "===== PAINEL: BAIXO, AUTO-OCULTAR, SEM DOCK FLUTUANTE ====="
if [ -n "$QDBUS" ]; then
  "$QDBUS" org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript '
var ps = panels();
for (var i = 0; i < ps.length; i++) {
  ps[i].location = "bottom";
  ps[i].hiding = "autohide";
  ps[i].floating = false;
  ps[i].lengthMode = "fill";
  ps[i].height = 40;
}
' || echo "Aviso: não consegui alterar painel via qdbus; restante do tema foi aplicado."
else
  echo "Aviso: qdbus ausente; não alterei painel via script."
fi

echo
echo "===== DOLPHIN / USABILIDADE LEVE ====="
"$KWRITE" --file dolphinrc --group General --key ShowFullPath true
"$KWRITE" --file dolphinrc --group General --key RememberOpenedTabs false

echo
echo "===== RECARREGANDO KDE SEM REBOOT ====="
if command -v kbuildsycoca6 >/dev/null 2>&1; then
  kbuildsycoca6 --noincremental || true
elif command -v kbuildsycoca5 >/dev/null 2>&1; then
  kbuildsycoca5 --noincremental || true
fi

if [ -n "$QDBUS" ]; then
  "$QDBUS" org.kde.KWin /KWin reconfigure || true
fi

if systemctl --user list-unit-files 2>/dev/null | grep -q '^plasma-plasmashell.service'; then
  systemctl --user restart plasma-plasmashell.service || true
else
  if command -v kquitapp6 >/dev/null 2>&1; then
    kquitapp6 plasmashell || true
  elif command -v kquitapp5 >/dev/null 2>&1; then
    kquitapp5 plasmashell || true
  else
    killall plasmashell 2>/dev/null || true
  fi
  sleep 1
  nohup plasmashell > "$SNAP/runtime/plasmashell-restart.log" 2>&1 &
fi

echo
echo "===== VALIDAÇÃO ====="
echo "ColorScheme:"
"$KREAD" --file kdeglobals --group General --key ColorScheme 2>/dev/null || true
echo "AccentColor:"
"$KREAD" --file kdeglobals --group General --key AccentColor 2>/dev/null || true
echo "Icon theme:"
"$KREAD" --file kdeglobals --group Icons --key Theme 2>/dev/null || true
echo "AnimationDurationFactor:"
"$KREAD" --file kdeglobals --group KDE --key AnimationDurationFactor 2>/dev/null || true
echo

cat > "$SNAP/manifest.txt" <<EOF
Mocha KDE theme snapshot/apply
timestamp=$TS
snapshot=$SNAP
desktop_info=$DESKTOP_INFO
icon_theme=$ICON_THEME
scheme=MochaKDE
panel=bottom/autohide/non-floating/fill
animations=disabled/reduced
EOF

echo "===== PRONTO ====="
echo "Snapshot salvo em:"
echo "$SNAP"
echo
echo "Se ficar visualmente bom, depois registramos esse estado como plasma-visual-bom."
