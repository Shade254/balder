#!/bin/bash
# ── battery.sh ─────────────────────────────────────────────
# Description: Shows battery % with ASCII bar + dynamic tooltip
# Usage: Waybar `custom/battery` every 10s
# Dependencies: upower, awk, seq, printf
#  ──────────────────────────────────────────────────────────

# Calculate actual charge percentage from charge_now/charge_full
# (T2 Mac quirk: /sys/class/power_supply/BAT0/capacity shows % of original capacity, not current charge)
charge_now=$(cat /sys/class/power_supply/BAT0/charge_now 2>/dev/null)
charge_full=$(cat /sys/class/power_supply/BAT0/charge_full 2>/dev/null)
charge_full_design=$(cat /sys/class/power_supply/BAT0/charge_full_design 2>/dev/null)
status=$(cat /sys/class/power_supply/BAT0/status)

# Calculate actual charge percentage
if [[ -n "$charge_now" && -n "$charge_full" && "$charge_full" -gt 0 ]]; then
    capacity=$((charge_now * 100 / charge_full))
    # Cap at 100% (battery calibration can cause slight overflow)
    [ "$capacity" -gt 100 ] && capacity=100
else
    # Fallback to capacity file
    capacity=$(cat /sys/class/power_supply/BAT0/capacity)
    [ "$capacity" -gt 100 ] && capacity=100
fi

# Calculate battery health (current capacity vs design capacity)
if [[ -n "$charge_full" && -n "$charge_full_design" && "$charge_full_design" -gt 0 ]]; then
    health=$((charge_full * 100 / charge_full_design))
else
    health="N/A"
fi

# Get detailed info from upower
time_to_empty_raw=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0 | awk -F: '/time to empty/ {print $2}' | xargs)
time_to_full_raw=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0 | awk -F: '/time to full/ {print $2}' | xargs)
cycle_count=$(cat /sys/class/power_supply/BAT0/cycle_count 2>/dev/null || echo "N/A")

# Convert time to short format (e.g., "1.6 hours" -> "1h 36m")
format_time() {
    local raw="$1"
    if [[ -z "$raw" ]]; then
        echo ""
        return
    fi
    local value=$(echo "$raw" | awk '{print $1}')
    local unit=$(echo "$raw" | awk '{print $2}')
    if [[ "$unit" == "hours" || "$unit" == "hour" ]]; then
        local hours=${value%.*}
        local frac=$(echo "$value $hours" | awk '{printf "%.0f", ($1 - $2) * 60}')
        [[ -z "$hours" ]] && hours=0
        if [[ "$frac" -gt 0 ]]; then
            echo "${hours}h ${frac}m"
        else
            echo "${hours}h"
        fi
    elif [[ "$unit" == "minutes" || "$unit" == "minute" ]]; then
        echo "${value%.*}m"
    else
        echo "$raw"
    fi
}

time_to_empty=$(format_time "$time_to_empty_raw")
time_to_full=$(format_time "$time_to_full_raw")

# Icons
charging_icons=(󰢜 󰂆 󰂇 󰂈 󰢝 󰂉 󰢞 󰂊 󰂋 󰂅)
default_icons=(󰁺 󰁻 󰁼 󰁽 󰁾 󰁿 󰂀 󰂁 󰂂 󰁹)

index=$((capacity / 10))
[ $index -ge 10 ] && index=9

if [[ "$status" == "Charging" ]]; then
    icon=${charging_icons[$index]}
elif [[ "$status" == "Full" ]]; then
    icon="󰂅"
else
    icon=${default_icons[$index]}
fi

# ASCII bar (10 segments)
filled=$((capacity / 10))
[ "$filled" -gt 10 ] && filled=10
empty=$((10 - filled))

bar=""
pad=""
[ "$filled" -gt 0 ] && bar=$(printf '█%.0s' $(seq 1 $filled))
[ "$empty" -gt 0 ] && pad=$(printf '░%.0s' $(seq 1 $empty))
ascii_bar="[$bar$pad]"

# Color thresholds
if [ "$capacity" -lt 20 ]; then
    fg="#bf616a"  # red
elif [ "$capacity" -lt 55 ]; then
    fg="#fab387"  # orange
else
    fg="#56b6c2"  # cyan
fi

# Build tooltip
# Format: "Status: time" / "Health: percentage (N cycles)"
if [[ "$status" == "Charging" ]]; then
    if [[ -n "$time_to_full" ]]; then
        line1="Charging: $time_to_full"
    else
        line1="Charging"
    fi
elif [[ "$status" == "Full" ]]; then
    line1="Fully Charged"
else
    if [[ -n "$time_to_empty" ]]; then
        line1="Discharging: $time_to_empty"
    else
        line1="Discharging"
    fi
fi

tooltip="$line1\nHealth: ${health}% (${cycle_count} cycles)"

# JSON output
echo "{\"text\":\"<span foreground='$fg'>$icon $ascii_bar $capacity%</span>\",\"tooltip\":\"$tooltip\"}"

