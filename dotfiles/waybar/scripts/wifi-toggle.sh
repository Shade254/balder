#!/bin/bash
# ── wifi-toggle.sh ───────────────────────────────────────────
# Description: Toggle WiFi ON/OFF, opens nmtui when turning ON
# Usage: Waybar `custom/wifi` on-click
# Dependencies: nmcli, alacritty (or other terminal)
# ─────────────────────────────────────────────────────────────

wifi_status=$(nmcli radio wifi)

if [ "$wifi_status" = "enabled" ]; then
    # WiFi is ON → turn OFF
    nmcli radio wifi off
else
    # WiFi is OFF → turn ON and open nmtui
    nmcli radio wifi on
    sleep 0.5
    alacritty -e nmtui &
fi
