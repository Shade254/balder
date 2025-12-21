#!/usr/bin/env bash
# ~/.config/eww/scripts/net/net_vpn_status.sh
# Show NordVPN status + country (for Eww) - T2 Mac version

status=$(nordvpn status 2>/dev/null | grep -i "status" | head -1 | awk '{print $2}')

if [[ "$status" == "Connected" ]]; then
  country=$(nordvpn status | grep -i "country" | awk '{print $2}')
  [[ -z "$country" ]] && country="CONNECTED"
  echo "[ФАНТОМ]"
else
  echo "KAPUTT"
fi
