#!/usr/bin/env bash
set -euo pipefail

REPO="${1:-/media/mochafast/MochaKde}"
HOST="${2:-mocha-kde-hal}"
export NIX_CONFIG="experimental-features = nix-command flakes"

echo "===== VALIDAR BASE DO MONTA MOCHA KDE ====="
echo "Repo: $REPO"
echo "Host: $HOST"

test -f "$REPO/flake.nix"
test -f "$REPO/nixos-machines/hal/configuration.nix"
test -f "$REPO/kde/modules/mocha-bluetooth-bluez.nix"
grep -q "mocha-bluetooth-bluez.nix" "$REPO/nixos-machines/hal/configuration.nix"

BT="$(nix eval --json "$REPO#nixosConfigurations.$HOST.config.hardware.bluetooth.enable")"
BM="$(nix eval --json "$REPO#nixosConfigurations.$HOST.config.services.blueman.enable")"
KERNEL="$(nix eval --raw "$REPO#nixosConfigurations.$HOST.config.boot.kernelPackages.kernel.version")"

echo "hardware.bluetooth.enable = $BT"
echo "services.blueman.enable    = $BM"
echo "kernel                     = $KERNEL"

[ "$BT" = "true" ] || { echo "ERRO: hardware.bluetooth.enable precisa ser true no MochaKde base."; exit 20; }
[ "$BM" = "true" ] || { echo "ERRO: services.blueman.enable precisa ser true no MochaKde base."; exit 21; }

echo "OK: base MochaKde inclui Bluetooth/BlueZ por padrao."
