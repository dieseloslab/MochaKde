#!/usr/bin/env bash
set -euo pipefail

echo "===== STATUS ====="
nordvpn status || true
ip route get 1.1.1.1 || true

echo
echo "===== TRACE ====="
curl -4 -fsS --connect-timeout 10 --max-time 20 https://www.cloudflare.com/cdn-cgi/trace \
  | grep -E '^(ip|loc|colo|warp|http|tls)=' || true

echo
echo "===== LATENCIA HTTPS CLOUDFLARE ====="
for i in 1 2 3 4 5; do
  curl -4 -o /dev/null -sS \
    --connect-timeout 10 \
    --max-time 20 \
    -w "cloudflare teste=$i dns=%{time_namelookup}s connect=%{time_connect}s tls=%{time_appconnect}s first_byte=%{time_starttransfer}s total=%{time_total}s\n" \
    https://www.cloudflare.com/cdn-cgi/trace || true
done

echo
echo "===== LATENCIA HTTPS GOOGLE ====="
for i in 1 2 3 4 5; do
  curl -4 -o /dev/null -sS \
    --connect-timeout 10 \
    --max-time 20 \
    -w "google teste=$i dns=%{time_namelookup}s connect=%{time_connect}s tls=%{time_appconnect}s first_byte=%{time_starttransfer}s total=%{time_total}s\n" \
    https://www.google.com || true
done

echo
echo "===== DOWNLOAD 100MB OVH ====="
curl -4 -L -o /dev/null \
  --connect-timeout 15 \
  --max-time 180 \
  -w "total=%{time_total}s speed_bytes=%{speed_download}\n" \
  https://proof.ovh.net/files/100Mb.dat || true
