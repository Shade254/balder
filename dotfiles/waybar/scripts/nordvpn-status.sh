#!/bin/bash
# ──────────────────────────────────────────────────────────────────────────
#  nordvpn-status.sh - NordVPN Status Display for Waybar
#  Part of Balder Dotfiles - Dionysus Edition
# ──────────────────────────────────────────────────────────────────────────
# Description: Checks NordVPN connection status and displays current server
# Usage: Called by Waybar `custom/vpn` every 5 seconds
# Dependencies: nordvpn CLI
# Output: Pango markup → [ФАНТОМ]: Connected location or KAPUTT
# Example: <span foreground='#a3be8c'>[ФАНТОМ]: Tokyo, Japan</span>
#          <span foreground='#bf616a'>[ФАНТОМ]: KAPUTT</span>
# ──────────────────────────────────────────────────────────────────────────

# Check if nordvpn is installed
if ! command -v nordvpn &> /dev/null; then
    echo "<span foreground='#bf616a'>[ФАНТОМ]: NO CLI</span>"
    exit 0
fi

# Get NordVPN status
STATUS=$(nordvpn status 2>/dev/null)

if echo "$STATUS" | grep -q "Status: Connected"; then
    # Extract server and country information
    SERVER=$(echo "$STATUS" | grep "Current server:" | awk '{print $3}')
    COUNTRY=$(echo "$STATUS" | grep "Country:" | awk '{print $2}')
    CITY=$(echo "$STATUS" | grep "City:" | awk '{print $2}')

    # Use country if available, otherwise use server name
    if [ -n "$COUNTRY" ]; then
        LOCATION="$COUNTRY"
        [ -n "$CITY" ] && LOCATION="$CITY, $COUNTRY"
    elif [ -n "$SERVER" ]; then
        LOCATION="$SERVER"
    else
        LOCATION="CONNECTED"
    fi

    # Connected - green color (#a3be8c is Nord green)
    echo "<span foreground='#a3be8c'>[ФАНТОМ]: $LOCATION</span>"
else
    # Disconnected - red color (#bf616a is Nord red)
    echo "<span foreground='#bf616a'>[ФАНТОМ]: KAPUTT</span>"
fi

