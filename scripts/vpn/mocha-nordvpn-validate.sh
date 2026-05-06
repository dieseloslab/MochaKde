#!/usr/bin/env bash
set -euo pipefail
export PATH="$HOME/.local/bin:$HOME/.nix-profile/bin:/etc/profiles/per-user/$USER/bin:/run/current-system/sw/bin:$PATH"

echo "===== NORDVPN STATUS ====="
nordvpn status || true

echo
echo "===== NORDVPN SETTINGS ====="
nordvpn settings || true

echo
echo "===== SERVICO ====="
systemctl status nordvpnd --no-pager || true

echo
echo "===== SOCKET / GRUPOS ====="
ls -ld /run/nordvpn /run/nordvpn/nordvpnd.sock 2>/dev/null || true
id

echo
echo "===== ROTA ====="
ip route get 1.1.1.1 || true

echo
echo "===== TRACE ====="
curl -4 -fsS --connect-timeout 10 --max-time 20 https://www.cloudflare.com/cdn-cgi/trace \
  | grep -E '^(ip|loc|colo|warp|http|tls)=' || true

echo
echo "===== PROCESSOS ====="
pgrep -a -i 'nord|vpn|warp' || true
