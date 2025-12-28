#!/bin/bash
# ── bluetooth.sh ─────────────────────────────────────────────
# Description: Shows Bluetooth status with connected devices + battery
# Usage: Waybar `custom/bluetooth` module every 5s
# Dependencies: bluetoothctl, rfkill
# ─────────────────────────────────────────────────────────────

# Check if Bluetooth is blocked
if rfkill list bluetooth | grep -q "Soft blocked: yes"; then
    echo "{\"text\":\"[ 󰂲 ]\",\"tooltip\":\"Bluetooth OFF\",\"class\":\"disabled\"}"
    exit 0
fi

# Get connected devices
connected_devices=$(bluetoothctl devices Connected 2>/dev/null)

if [ -z "$connected_devices" ]; then
    echo "{\"text\":\"[ 󰂯 ]\",\"tooltip\":\"Bluetooth ON\",\"class\":\"disconnected\"}"
    exit 0
fi

# Build tooltip with device info only (no header)
tooltip=""
first=true

while IFS= read -r line; do
    mac=$(echo "$line" | awk '{print $2}')
    name=$(echo "$line" | cut -d' ' -f3-)

    if [ -n "$mac" ] && [ -n "$name" ]; then
        device_info=$(bluetoothctl info "$mac" 2>/dev/null)
        battery=$(echo "$device_info" | grep "Battery Percentage" | sed 's/.*(\([0-9]*\)).*/\1/')
        icon_type=$(echo "$device_info" | grep "Icon:" | awk '{print $2}')

        # Determine device icon - check Icon field first, then UUIDs
        if [ -n "$icon_type" ]; then
            case "$icon_type" in
                audio-headset|audio-headphones) device_icon="󰋋" ;;
                audio-card) device_icon="󰓃" ;;
                input-keyboard) device_icon="󰌌" ;;
                input-mouse) device_icon="󰍽" ;;
                phone) device_icon="󰏲" ;;
                *) device_icon="󰂱" ;;
            esac
        elif echo "$device_info" | grep -qE "UUID:.*(Headset|Audio Sink|Handsfree)"; then
            device_icon="󰋋"  # Audio device
        elif echo "$device_info" | grep -q "UUID:.*Human Interface"; then
            device_icon="󰌌"  # Keyboard/input
        else
            device_icon="󰂱"  # Generic bluetooth
        fi

        # Add newline between devices
        [ "$first" = true ] && first=false || tooltip="$tooltip\\n"

        # Format: "icon  name" and "icon  battery%" with proper spacing
        if [ -n "$battery" ]; then
            tooltip="$tooltip$device_icon  $name\\n󰁹  $battery%"
        else
            tooltip="$tooltip$device_icon  $name"
        fi
    fi
done <<< "$connected_devices"

echo "{\"text\":\"[ 󰂱 ]\",\"tooltip\":\"$tooltip\",\"class\":\"connected\"}"
