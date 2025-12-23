#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
#  net_ping.sh
#  Measures ICMP ping latency to 1.1.1.1 (Cloudflare DNS).
#
#  Output: "latency_text|percent" (pipe-separated)
#  Example: "24 мс|24" or "0 мс|0"
#
#  Max: 100 ms = 100%
# ─────────────────────────────────────────────────────────────────────────────

MAX_MS=50  # 50ms max (VPN latency typically 20-40ms)

# Ping with 1 second timeout
ms=$(ping -c 1 -W 1 1.1.1.1 2>/dev/null | grep 'time=' | awk -F'time=' '{print int($2)}')

# Handle timeout/failure
if [[ -z "$ms" ]] || [[ "$ms" -eq 0 ]]; then
  echo "-- мс|0"
  exit 0
fi

# Calculate percentage (linear scale, max 100 ms)
percent=$((ms * 100 / MAX_MS))
[[ $percent -gt 100 ]] && percent=100

echo "${ms} мс|${percent}"
