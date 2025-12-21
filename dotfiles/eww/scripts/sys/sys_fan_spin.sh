#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
#  Script: sys_fan_spin.sh
#  Purpose: Displays fan spinner animation (CPU/GPU) based on RPM
#  Example:
#      ./sys_fan_spin.sh cpu
# ─────────────────────────────────────────────────────────────────────────────


SPIN=('|' '/' '-' '\\')
fan="$1"

# Simple cache file to track frame index across calls
cache="/tmp/${fan}_fan_frame"

if [ -f "$cache" ]; then
  index=$(<"$cache")
else
  index=0
fi

# Advance frame
index=$(( (index + 1) % ${#SPIN[@]} ))
echo "$index" > "$cache"

# Get RPM - T2 Mac uses fan1 (left) and fan2 (right)
# Supports both legacy (cpu/gpu) and new (left/right) params
if [ "$fan" = "left" ] || [ "$fan" = "cpu" ]; then
  rpm=$(sensors | grep -E '^fan1:' | awk '{print $2}')
elif [ "$fan" = "right" ] || [ "$fan" = "gpu" ]; then
  rpm=$(sensors | grep -E '^fan2:' | awk '{print $2}')
else
  rpm=0
fi
[ -z "$rpm" ] && rpm=0

if [ "$rpm" -eq 0 ]; then
  echo "|"
else
  echo "${SPIN[$index]}"
fi

