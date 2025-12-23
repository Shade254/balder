#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
#  net_vpn_bar.sh
#  Renders a 5-line VPN status bar from percentage input.
#  Uses Pango markup for tight line spacing.
#
#  Usage: ./net_vpn_bar.sh <percent>
#  Example: ./net_vpn_bar.sh 100  → full bar (connected)
#           ./net_vpn_bar.sh 0    → empty bar (disconnected)
# ─────────────────────────────────────────────────────────────────────────────

percent=${1:-0}
lines=10

# VPN is binary: 100 = full, anything else = empty
if [[ "$percent" -ge 100 ]]; then
  filled=$lines
else
  filled=0
fi

# Build output with Pango markup for tight line spacing
output='<span line_height="0.6">'
for ((i=0; i<lines; i++)); do
  row=$((lines - i))
  if (( row <= filled )); then
    output+="█"
  else
    output+="│"
  fi
  if (( i < lines - 1 )); then
    output+="&#10;"
  fi
done
output+='</span>'

printf '%s' "$output"
