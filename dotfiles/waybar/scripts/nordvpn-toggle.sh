#!/bin/bash
# ──────────────────────────────────────────────────────────────────────────
#  nordvpn-toggle.sh - NordVPN Connection Toggle for Waybar
#  Part of Balder Dotfiles - Dionysus Edition
# ──────────────────────────────────────────────────────────────────────────
# Description: Toggle NordVPN connection on/off with smart reconnection
# Usage: Called by Waybar `custom/vpn` on click
# Dependencies: nordvpn CLI, notify-send (optional)
# ──────────────────────────────────────────────────────────────────────────

# Check if nordvpn is installed
if ! command -v nordvpn &> /dev/null; then
    notify-send "NordVPN" "NordVPN CLI not installed" -u critical 2>/dev/null
    exit 1
fi

# Get current status
STATUS=$(nordvpn status 2>/dev/null)

if echo "$STATUS" | grep -q "Status: Connected"; then
    # VPN is connected → disconnect
    nordvpn disconnect &>/dev/null
    notify-send "NordVPN" "Disconnected from VPN" -u normal 2>/dev/null
else
    # VPN is disconnected → connect to fastest server
    # You can customize this to connect to a specific country/city:
    # nordvpn connect Japan
    # nordvpn connect US Los_Angeles
    nordvpn connect &>/dev/null &
    notify-send "NordVPN" "Connecting to fastest server..." -u normal 2>/dev/null
fi

