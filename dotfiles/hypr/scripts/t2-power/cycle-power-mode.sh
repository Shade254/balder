#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
#  Cycles Intel EPP power profiles (REACTOR SLEEP → STABILIZATION → RAZGON).
#  Uses native Intel P-State energy_performance_preference sysfs interface.
#  Bound to XF86Launch4 (F5) in Hyprland config.
# ─────────────────────────────────────────────────────────────────────────────

set -e

# EPP sysfs path
EPP_PATH="/sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference"
LOCK_FILE="/run/user/$UID/power-mode.lock"

# Acquire lock (prevent concurrent execution)
exec 200>"$LOCK_FILE"
flock -n 200 || { echo "Power mode change already in progress"; exit 0; }

# Check if EPP is available
if [[ ! -f "$EPP_PATH" ]]; then
    echo "ERROR: Intel EPP not available. Check CPU supports P-State driver."
    exit 1
fi

# Read current EPP
CURRENT=$(cat "$EPP_PATH")

# Determine next profile
case "$CURRENT" in
    power)
        NEXT="balance_performance"
        ;;
    balance_performance)
        NEXT="performance"
        ;;
    performance)
        NEXT="power"
        ;;
    *)
        # Unknown or default - start cycle
        NEXT="power"
        ;;
esac

# Write new EPP to all CPU cores
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference; do
    echo "$NEXT" > "$cpu" 2>/dev/null || {
        echo "ERROR: Cannot write to EPP. Run: sudo cp dotfiles/system/99-cpu-epp.rules /etc/udev/rules.d/ && sudo udevadm control --reload"
        exit 1
    }
done

# Signal Waybar to update widget (event-driven)
pkill -USR1 waybar 2>/dev/null || true

# Release lock (automatic on script exit)
