#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════════════════════
#  Hyprlock wrapper for MANUAL locking (CMD+L)
#  - Turns screen off after 30 seconds
#  - Monitors Hyprland events to wake screen on ANY input (keyboard/mouse)
# ══════════════════════════════════════════════════════════════════════════════

# Turn ALL screens on before showing lock (in case they were off)
~/.config/hypr/scripts/wake-all-displays.sh

# Start hyprlock in background
hyprlock &
HYPRLOCK_PID=$!

# Background process: DPMS control + input monitoring
(
    # Wait 90 seconds (1m30s) before turning screen off
    sleep 90

    # If still locked, turn ALL screens off
    if pgrep -x hyprlock > /dev/null; then
        # Turn off all monitors
        hyprctl monitors -j | jq -r '.[].name' | while read -r monitor; do
            hyprctl dispatch dpms off "$monitor"
        done

        # NOW THE CRITICAL FIX: Monitor Hyprland events for input
        # This listens to Hyprland's event socket and wakes screen on ANY input
        if [[ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]]; then
            socat -u UNIX-CONNECT:/tmp/hypr/"$HYPRLAND_INSTANCE_SIGNATURE"/.socket2.sock - 2>/dev/null | \
            while IFS= read -r event; do
                # Check if hyprlock is still running
                if ! pgrep -x hyprlock > /dev/null; then
                    break
                fi

                # On ANY event (keyboard, mouse, etc), check if ANY screen is off
                # If ANY off, wake ALL displays!
                ANY_OFF=$(hyprctl monitors -j | jq -r 'any(.dpmsStatus == false)' 2>/dev/null)
                if [[ "$ANY_OFF" == "true" ]]; then
                    ~/.config/hypr/scripts/wake-all-displays.sh
                fi
            done
        fi
    fi
) &
MONITOR_PID=$!

# Wait for hyprlock to finish (user unlocked)
wait $HYPRLOCK_PID

# Cleanup background monitor
kill $MONITOR_PID 2>/dev/null
wait $MONITOR_PID 2>/dev/null

# Ensure ALL screens are on after unlocking
~/.config/hypr/scripts/wake-all-displays.sh
