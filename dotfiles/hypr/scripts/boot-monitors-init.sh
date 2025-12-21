#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════════════════════
#  Boot Monitor Initialization Fix
#  Fixes greetd race condition where external monitors aren't ready at launch
# ══════════════════════════════════════════════════════════════════════════════

# Wait for display hardware to fully initialize (greetd timing issue)
sleep 2.5

# Force Hyprland to re-detect and configure ALL monitors
# This reloads the monitor configuration from hyprland.conf
hyprctl keyword monitor "eDP-1,preferred,0x1440,1.25"
hyprctl keyword monitor "DP-1,preferred,0x0,1.5"
hyprctl keyword monitor ",preferred,auto,1"

# Wake all displays (in case any are in DPMS off state)
hyprctl monitors -j | jq -r '.[].name' | while read -r monitor; do
    hyprctl dispatch dpms on "$monitor"
done

# Ensure both monitors have their default workspaces active
# External monitor (DP-1) → workspace 5
hyprctl dispatch workspace 5

# Laptop display (eDP-1) → workspace 1 (and focus it)
hyprctl dispatch workspace 1
hyprctl dispatch focusmonitor eDP-1
