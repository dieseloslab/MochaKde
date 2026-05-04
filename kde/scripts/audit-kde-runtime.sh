#!/usr/bin/env bash
set -euo pipefail

REPO="/media/mochafast/MochaKde"
TS="$(date +%Y%m%d-%H%M%S)"
LOG="$REPO/logs/kde-runtime-audit-$TS.log"

mkdir -p "$REPO/logs"

{
  echo "===== MOCHA KDE RUNTIME AUDIT - $TS ====="
  echo

  echo "===== OS ====="
  cat /etc/os-release 2>/dev/null || true
  echo

  echo "===== KERNEL ====="
  uname -a
  echo

  echo "===== SESSION ====="
  echo "XDG_SESSION_TYPE=${XDG_SESSION_TYPE:-}"
  echo "XDG_CURRENT_DESKTOP=${XDG_CURRENT_DESKTOP:-}"
  echo "DESKTOP_SESSION=${DESKTOP_SESSION:-}"
  loginctl show-session "${XDG_SESSION_ID:-}" -p Type -p Desktop -p Name -p State 2>/dev/null || true
  echo

  echo "===== KDE / PLASMA ====="
  plasmashell --version 2>/dev/null || true
  kwin_wayland --version 2>/dev/null || true
  kf6-config --version 2>/dev/null || true
  echo

  echo "===== NVIDIA ====="
  command -v nvidia-smi || true
  nvidia-smi 2>/dev/null | sed -n '1,25p' || true
  echo
  nvidia-smi --query-gpu=name,driver_version,pstate,power.draw,power.limit,clocks.gr,clocks.mem,memory.used,memory.total,utilization.gpu,utilization.memory --format=csv 2>/dev/null || true
  echo

  echo "===== VULKAN / OPENGL ====="
  command -v vulkaninfo || true
  vulkaninfo --summary 2>/dev/null | sed -n '1,80p' || true
  echo
  glxinfo -B 2>/dev/null || true
  echo

  echo "===== STEAM / GAMING ====="
  command -v steam || true
  command -v mangohud || true
  command -v gamemoded || true
  command -v gamescope || true
  mangohud --version 2>/dev/null || true
  gamemoded -s 2>/dev/null || true
  echo

  echo "===== TUNED ====="
  command -v tuned-adm || true
  tuned-adm active 2>/dev/null || true
  echo

  echo "===== FIM ====="
} | tee "$LOG"

echo
echo "Log salvo em: $LOG"
