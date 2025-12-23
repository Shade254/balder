#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
#  net_vpn.sh
#  Checks NordVPN connection status.
#
#  Output: "status_text|percent" (pipe-separated)
#  Connected:    "[ФАНТОМ]|100"
#  Disconnected: "[нуль]|0"
# ─────────────────────────────────────────────────────────────────────────────

status=$(nordvpn status 2>/dev/null | grep -i "^Status:" | awk '{print $2}')

if [[ "$status" == "Connected" ]]; then
  echo "[ФАНТОМ]|100"
else
  echo "[НУЛЬ]|0"
fi
