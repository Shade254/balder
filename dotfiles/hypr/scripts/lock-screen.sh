#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════════════════════
#  Hyprlock wrapper for MANUAL locking (CMD+L)
#  - Turns screen off after 30 seconds
#  - Monitors Hyprland events to wake screen on ANY input (keyboard/mouse)
# ══════════════════════════════════════════════════════════════════════════════

# Turn screen on before showing lock (in case it was off)
hyprctl dispatch dpms on

# Start hyprlock in background
hyprlock &
HYPRLOCK_PID=$!

# Background process: DPMS control + input monitoring
(
    # Wait 90 seconds (1m30s) before turning screen off
    sleep 90

    # If still locked, turn screen off
    if pgrep -x hyprlock > /dev/null; then
        hyprctl dispatch dpms off

        # NOW THE CRITICAL FIX: Monitor Hyprland events for input
        # This listens to Hyprland's event socket and wakes screen on ANY input
        if [[ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]]; then
            socat -u UNIX-CONNECT:/tmp/hypr/"$HYPRLAND_INSTANCE_SIGNATURE"/.socket2.sock - 2>/dev/null | \
            while IFS= read -r event; do
                # Check if hyprlock is still running
                if ! pgrep -x hyprlock > /dev/null; then
                    break
                fi

                # On ANY event (keyboard, mouse, etc), check if screen is off
                # If off, turn it back on!
                DPMS_STATUS=$(hyprctl monitors -j | jq -r '.[0].dpmsStatus' 2>/dev/null)
                if [[ "$DPMS_STATUS" == "false" ]]; then
                    hyprctl dispatch dpms on
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

# Ensure screen is on after unlocking
hyprctl dispatch dpms on
