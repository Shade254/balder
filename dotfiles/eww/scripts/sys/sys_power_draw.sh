#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
#  Script: sys_power_draw.sh
#  Purpose: Get current power draw from UPower with charging state indicator
#  Output: "25.2 Вт↑" (charging) or "25.2 Вт↓" (discharging) or "0.0 Вт" (full)
# ─────────────────────────────────────────────────────────────────────────────

# Get UPower output for battery
upower_output=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0 2>/dev/null)

if [ -z "$upower_output" ]; then
  echo "N/A"
  exit 0
fi

# Parse energy-rate (power in watts)
energy_rate=$(echo "$upower_output" | grep 'energy-rate:' | awk '{print $2}')

# Parse state (charging/discharging/fully-charged)
state=$(echo "$upower_output" | grep 'state:' | awk '{print $2}')

# Handle missing values
if [ -z "$energy_rate" ]; then
  echo "N/A"
  exit 0
fi

# Format output based on state (using Cyrillic Вт for Watts)
case "$state" in
  charging)
    printf "%.1f Вт↑\n" "$energy_rate"
    ;;
  discharging)
    printf "%.1f Вт↓\n" "$energy_rate"
    ;;
  fully-charged)
    echo "0.0 Вт"
    ;;
  *)
    printf "%.1f Вт\n" "$energy_rate"
    ;;
esac
