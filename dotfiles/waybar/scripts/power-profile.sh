#!/bin/bash
# ── power-profile.sh ───────────────────────────────────────
# Description: Display current Intel EPP power profile with color
# Usage: Called by Waybar `custom/power-profile`
# Dependencies: sysfs Intel EPP interface
# ──────────────────────────────────────────────────────────

EPP_PATH="/sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference"

# Read current EPP (graceful fallback if not available)
if [[ -f "$EPP_PATH" ]]; then
    profile=$(cat "$EPP_PATH" 2>/dev/null)
else
    profile="unknown"
fi

# Map EPP to nuclear theme output
case "$profile" in
  performance)
    text="RAZGON"
    fg="#bf616a"
    ;;
  balance_performance)
    text="STABILIZATION"
    fg="#fab387"
    ;;
  power)
    text="REACTOR SLEEP"
    fg="#56b6c2"
    ;;
  *)
    text="EPP ??"
    fg="#ffffff"
    ;;
esac

# Output Pango markup for Waybar
echo "<span foreground='$fg'>$text</span>"
