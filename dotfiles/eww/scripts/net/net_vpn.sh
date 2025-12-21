#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
#  net_vpn.sh
#  Checks if NordVPN is connected, outputs 100 (on) or 0 (off).
#  T2 Mac version - uses NordVPN CLI
# ─────────────────────────────────────────────────────────────────────────────

status=$(nordvpn status 2>/dev/null | grep -i "status" | head -1 | awk '{print $2}')

if [[ "$status" == "Connected" ]]; then
  echo 100
else
  echo 0
fi
