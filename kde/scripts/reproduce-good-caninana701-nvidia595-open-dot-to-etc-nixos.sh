#!/usr/bin/env bash
set -euo pipefail

SUDO="/run/wrappers/bin/sudo"
[ -x "$SUDO" ] || SUDO="$(command -v sudo)"

"$SUDO" -v
while true; do "$SUDO" -n true 2>/dev/null || exit; sleep 30; done &
SUDO_KEEPALIVE_PID="$!"
trap 'kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true' EXIT

REPO="${1:-/media/mochafast/MochaKde}"
TARGET="${2:-/etc/nixos}"
GOOD="$REPO/kde/caninana-reference/good/caninana701-nvidia595-open-dot-20260505-201924"
TS="$(date +%Y%m%d-%H%M%S)"
BACKUP="/media/mochafast/mocha-backups/etc-nixos-before-restore-caninana701-nvidia595-open-dot-$TS"

echo "===== RESTAURAR RECEITA BOA CANINANA 701 NVIDIA 595 OPEN DOT ====="
echo "Repo: $REPO"
echo "Target: $TARGET"
echo "Good: $GOOD"
echo "Backup: $BACKUP"

test -d "$REPO"
test -d "$TARGET"
test -d "$GOOD"

test -f "$GOOD/nvidia-pinned.FONTE-ATIVA-BOA.nix"
test -f "$GOOD/caninana-kernel.FONTE-ATIVA-BOA.nix"
test -f "$GOOD/mocha-dns-cloudflare-dot.FONTE-ATIVA-BOA.nix"

grep -q 'open = true' "$GOOD/nvidia-pinned.FONTE-ATIVA-BOA.nix"
grep -q '595.71.05' "$GOOD/nvidia-pinned.FONTE-ATIVA-BOA.nix"
grep -q 'DNSOverTLS' "$GOOD/mocha-dns-cloudflare-dot.FONTE-ATIVA-BOA.nix"
grep -q '1.1.1.1#one.one.one.one' "$GOOD/mocha-dns-cloudflare-dot.FONTE-ATIVA-BOA.nix"

mkdir -p "$BACKUP"
"$SUDO" cp -a "$TARGET" "$BACKUP/etc-nixos"
"$SUDO" chown -R "$USER:users" "$BACKUP" 2>/dev/null || true

"$SUDO" mkdir -p "$TARGET/kde/modules"
"$SUDO" cp -a "$GOOD/nvidia-pinned.FONTE-ATIVA-BOA.nix" "$TARGET/kde/modules/nvidia-pinned.nix"
"$SUDO" cp -a "$GOOD/caninana-kernel.FONTE-ATIVA-BOA.nix" "$TARGET/kde/modules/caninana-kernel.nix"
"$SUDO" cp -a "$GOOD/mocha-dns-cloudflare-dot.FONTE-ATIVA-BOA.nix" "$TARGET/kde/modules/mocha-dns-cloudflare-dot.nix"

"$SUDO" grep -RIn 'open = true\|595.71.05\|DNSOverTLS\|1.1.1.1#one.one.one.one' \
  "$TARGET/kde/modules/nvidia-pinned.nix" \
  "$TARGET/kde/modules/caninana-kernel.nix" \
  "$TARGET/kde/modules/mocha-dns-cloudflare-dot.nix"

echo "OK: módulos copiados para /etc/nixos."
echo "Nao foi feito rebuild, boot ou switch."
