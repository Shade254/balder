#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
#  net_download.sh
#  Measures download speed with auto-detected interface.
#
#  Output: "speed_text|percent" (pipe-separated)
#  Example: "12.5 MБ|25" or "842 КБ|2"
#
#  Auto-scale: <1 MB/s → КБ (0 decimals), ≥1 MB/s → MБ (1 decimal)
#  Max: 50 MB/s = 100%
# ─────────────────────────────────────────────────────────────────────────────

MAX_BPS=$((5 * 1024 * 1024))  # 5 MB/s in bytes (realistic for WiFi/VPN usage)

# Auto-detect interface: NordVPN → ethernet → wifi
detect_interface() {
  # NordVPN tunnel (nordlynx)
  if ip link show nordlynx &>/dev/null && [[ $(cat /sys/class/net/nordlynx/operstate 2>/dev/null) == "unknown" ]]; then
    echo "nordlynx"
    return
  fi

  # Ethernet interfaces
  for iface in eth0 enp*; do
    if [[ -d /sys/class/net/$iface ]] && [[ $(cat /sys/class/net/$iface/operstate 2>/dev/null) == "up" ]]; then
      echo "$iface"
      return
    fi
  done

  # WiFi (default fallback)
  for iface in wlan0 wlp*; do
    if [[ -d /sys/class/net/$iface ]] && [[ $(cat /sys/class/net/$iface/operstate 2>/dev/null) == "up" ]]; then
      echo "$iface"
      return
    fi
  done

  echo "wlan0"
}

iface=$(detect_interface)

# Sample RX bytes (1 second interval)
rx1=$(awk -v iface="$iface" '$1 ~ iface":" {print $2}' /proc/net/dev 2>/dev/null)
sleep 1
rx2=$(awk -v iface="$iface" '$1 ~ iface":" {print $2}' /proc/net/dev 2>/dev/null)

# Handle missing data
if [[ -z "$rx1" ]] || [[ -z "$rx2" ]]; then
  echo "-- КБ|0"
  exit 0
fi

# Calculate bytes per second
bps=$((rx2 - rx1))
[[ $bps -lt 0 ]] && bps=0

# Calculate percentage (linear scale, max 50 MB/s)
percent=$((bps * 100 / MAX_BPS))
[[ $percent -gt 100 ]] && percent=100

# Format speed with auto-scale
if [[ $bps -ge 1048576 ]]; then
  # ≥1 MB/s → show in MБ with 1 decimal
  mb_int=$((bps / 1048576))
  mb_dec=$(( (bps % 1048576) * 10 / 1048576 ))
  speed="${mb_int}.${mb_dec} MБ"
else
  # <1 MB/s → show in КБ with 0 decimals
  kb=$((bps / 1024))
  speed="${kb} КБ"
fi

echo "${speed}|${percent}"
