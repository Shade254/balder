#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════════════════════
#  Wake ALL displays (not just focused monitor)
#  Used by hypridle on-resume and lock-screen script
# ══════════════════════════════════════════════════════════════════════════════

# Get all monitor names and turn DPMS on for each
hyprctl monitors -j | jq -r '.[].name' | while read -r monitor; do
    hyprctl dispatch dpms on "$monitor"
done
