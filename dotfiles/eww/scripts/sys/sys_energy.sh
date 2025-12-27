#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
#  Script: sys_energy.sh
#  Purpose: Get remaining battery energy in watt-hours from UPower
#  Output: "34.4 Вт·ч" (with Cyrillic unit)
# ─────────────────────────────────────────────────────────────────────────────

# Get UPower output for battery
upower_output=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0 2>/dev/null)

if [ -z "$upower_output" ]; then
  echo "N/A"
  exit 0
fi

# Parse energy (watt-hours)
energy=$(echo "$upower_output" | grep -E '^\s+energy:' | awk '{print $2}')

# Handle missing value
if [ -z "$energy" ]; then
  echo "N/A"
  exit 0
fi

# Format with Cyrillic unit
printf "%.1f Вт·ч\n" "$energy"
