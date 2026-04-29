#!/usr/bin/env bash
set -euo pipefail

# Diesel OS Lab / Mocha KDE
# Restaura o estado visual KDE considerado bom.
#
# Este script NAO roda nixos-rebuild.
# Este script NAO troca display manager.
# Este script NAO mexe em GDM/GNOME.
# Ele apenas copia configs visuais KDE/GTK previamente salvas.

RESTART_PLASMA="false"
FORCE="false"

for arg in "$@"; do
  case "$arg" in
    --restart-plasma)
      RESTART_PLASMA="true"
      ;;
    --force)
      FORCE="true"
      ;;
    *)
      echo "Argumento desconhecido: $arg"
      echo "Uso: $0 [--restart-plasma] [--force]"
      exit 2
      ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

STATE_DIR="$REPO_ROOT/kde/state/plasma-visual-bom-20260429-184141"

if [ ! -d "$STATE_DIR" ]; then
  echo "ERRO: diretorio de estado visual bom nao encontrado:"
  echo "$STATE_DIR"
  exit 1
fi

DESKTOP_INFO="${XDG_CURRENT_DESKTOP:-} ${DESKTOP_SESSION:-}"

if [ "$FORCE" != "true" ]; then
  case "$DESKTOP_INFO" in
    *KDE*|*Plasma*|*plasma*)
      ;;
    *)
      echo "ERRO: sessao atual nao parece ser KDE/Plasma."
      echo "XDG_CURRENT_DESKTOP=${XDG_CURRENT_DESKTOP:-}"
      echo "DESKTOP_SESSION=${DESKTOP_SESSION:-}"
      echo
      echo "Para aplicar mesmo assim, rode:"
      echo "$0 --force"
      exit 1
      ;;
  esac
fi

BACKUP_DIR="$HOME/.config/mocha-kde-backups/visual-before-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"
mkdir -p "$HOME/.config"

echo "===== MOCHA KDE - RESTAURANDO ESTADO VISUAL BOM ====="
echo "Origem:  $STATE_DIR"
echo "Backup:  $BACKUP_DIR"
echo

copy_config_file() {
  local name="$1"
  local src="$STATE_DIR/$name"
  local dst="$HOME/.config/$name"

  if [ -f "$src" ]; then
    if [ -f "$dst" ]; then
      cp "$dst" "$BACKUP_DIR/$name"
    fi

    cp "$src" "$dst"
    echo "OK: ~/.config/$name"
  else
    echo "IGNORADO, nao existe na origem: $name"
  fi
}

copy_config_file kdeglobals
copy_config_file plasmarc
copy_config_file kwinrc
copy_config_file kscreenlockerrc
copy_config_file kglobalshortcutsrc
copy_config_file plasma-org.kde.plasma.desktop-appletsrc
copy_config_file dolphinrc
copy_config_file gtkrc
copy_config_file gtkrc-2.0

if [ -f "$STATE_DIR/home-gtkrc-2.0" ]; then
  if [ -f "$HOME/.gtkrc-2.0" ]; then
    cp "$HOME/.gtkrc-2.0" "$BACKUP_DIR/home-gtkrc-2.0"
  fi

  cp "$STATE_DIR/home-gtkrc-2.0" "$HOME/.gtkrc-2.0"
  echo "OK: ~/.gtkrc-2.0"
fi

echo
echo "===== RECARREGANDO CACHE KDE, SE DISPONIVEL ====="
if command -v kbuildsycoca6 >/dev/null 2>&1; then
  kbuildsycoca6 --noincremental >/dev/null 2>&1 || true
  echo "OK: kbuildsycoca6"
elif command -v kbuildsycoca5 >/dev/null 2>&1; then
  kbuildsycoca5 --noincremental >/dev/null 2>&1 || true
  echo "OK: kbuildsycoca5"
else
  echo "AVISO: kbuildsycoca nao encontrado."
fi

echo
echo "===== RESUMO DO TEMA APLICADO ====="
grep -nE 'ColorScheme|LookAndFeelPackage|widgetStyle|Theme|Icons|iconTheme|cursorTheme|ColorSchemeHash' \
  "$HOME/.config/kdeglobals" "$HOME/.config/plasmarc" 2>/dev/null || true

if [ "$RESTART_PLASMA" = "true" ]; then
  echo
  echo "===== REINICIANDO PLASMA ====="

  if command -v kquitapp6 >/dev/null 2>&1 && command -v kstart >/dev/null 2>&1; then
    kquitapp6 plasmashell || true
    sleep 2
    kstart plasmashell || true
  elif command -v kquitapp5 >/dev/null 2>&1 && command -v kstart5 >/dev/null 2>&1; then
    kquitapp5 plasmashell || true
    sleep 2
    kstart5 plasmashell || true
  else
    echo "AVISO: nao encontrei comandos para reiniciar o Plasma."
    echo "Faca logout/login se necessario."
  fi
else
  echo
  echo "Plasma nao foi reiniciado."
  echo "Para aplicar e reiniciar o Plasma:"
  echo "$0 --restart-plasma"
fi

echo
echo "Concluido."
