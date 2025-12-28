#!/bin/bash
# ── wifi.sh ──────────────────────────────────────────────────
# Description: Shows WiFi status with signal strength icons
# Usage: Waybar `custom/wifi` module every 5s
# Dependencies: nmcli
# ─────────────────────────────────────────────────────────────

CACHE_FILE="/tmp/waybar-wifi-stats"
INTERFACE="wlan0"

# Check if WiFi radio is disabled
wifi_status=$(nmcli radio wifi)

if [ "$wifi_status" = "disabled" ]; then
    echo '{"text":"[ 󰤮 ]","tooltip":"WiFi OFF","class":"disabled"}'
    exit 0
fi

# WiFi is enabled - check connection
connection=$(nmcli -t -f ACTIVE,SSID,SIGNAL dev wifi list 2>/dev/null | grep "^yes" | head -1)

if [ -z "$connection" ]; then
    # Enabled but not connected
    echo '{"text":"[ 󰤫 ]","tooltip":"WiFi ON","class":"disconnected"}'
    exit 0
fi

# Connected - parse SSID and signal strength
ssid=$(echo "$connection" | cut -d':' -f2)
signal=$(echo "$connection" | cut -d':' -f3)

# Determine signal strength icon
if [ "$signal" -ge 80 ]; then
    icon="󰤨"
elif [ "$signal" -ge 60 ]; then
    icon="󰤥"
elif [ "$signal" -ge 40 ]; then
    icon="󰤢"
elif [ "$signal" -ge 20 ]; then
    icon="󰤟"
else
    icon="󰤯"
fi

# Get current bytes
rx_bytes=$(cat /sys/class/net/$INTERFACE/statistics/rx_bytes 2>/dev/null || echo 0)
tx_bytes=$(cat /sys/class/net/$INTERFACE/statistics/tx_bytes 2>/dev/null || echo 0)
now=$(date +%s)

# Read previous stats
if [ -f "$CACHE_FILE" ]; then
    read prev_rx prev_tx prev_time < "$CACHE_FILE"
    elapsed=$((now - prev_time))

    if [ "$elapsed" -gt 0 ]; then
        # Calculate speed in bytes/sec
        rx_speed=$(( (rx_bytes - prev_rx) / elapsed ))
        tx_speed=$(( (tx_bytes - prev_tx) / elapsed ))

        # Format speed (convert to KB/s or MB/s)
        format_speed() {
            local bytes=$1
            if [ "$bytes" -ge 1048576 ]; then
                echo "$(echo "scale=1; $bytes / 1048576" | bc) MB/s"
            elif [ "$bytes" -ge 1024 ]; then
                echo "$(echo "scale=1; $bytes / 1024" | bc) KB/s"
            else
                echo "$bytes B/s"
            fi
        }

        rx_fmt=$(format_speed $rx_speed)
        tx_fmt=$(format_speed $tx_speed)
    else
        rx_fmt="-- B/s"
        tx_fmt="-- B/s"
    fi
else
    rx_fmt="-- B/s"
    tx_fmt="-- B/s"
fi

# Save current stats for next run
echo "$rx_bytes $tx_bytes $now" > "$CACHE_FILE"

# Build tooltip
tooltip="Name: $ssid\\nStrength: ${signal}%\\nSpeed: ⇣ $rx_fmt  ⇡ $tx_fmt"

echo "{\"text\":\"[ $icon ]\",\"tooltip\":\"$tooltip\",\"class\":\"connected\"}"
