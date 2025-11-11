#!/usr/bin/env bash
# Lock screen with automatic screen-off after 30 seconds
# Used for MANUAL locking (CMD+L) to match swayidle behavior

# Turn screen on before showing lock
hyprctl dispatch dpms on

# Start hyprlock in background so we can monitor it
hyprlock &
HYPRLOCK_PID=$!

# Wait for hyprlock to start
sleep 0.5

# Monitor: turn screen off after 30s of being locked, then wake on any input
(
    # Wait 30 seconds before turning screen off
    sleep 30

    # Turn screen off if still locked
    if pgrep -x hyprlock > /dev/null; then
        hyprctl dispatch dpms off
    fi

    # Keep monitoring - if user provides input while screen is off, turn it back on
    # We use hypridle's approach: check periodically if there's been activity
    while pgrep -x hyprlock > /dev/null; do
        sleep 0.5

        # Get current dpms status
        DPMS_STATUS=$(hyprctl monitors -j | jq -r '.[0].dpmsStatus' 2>/dev/null)

        # If screen is off but hyprlock is running, we're in the "dark screen" state
        # The resume event from swayidle should turn it back on, but let's ensure it
        if [[ "$DPMS_STATUS" == "false" ]]; then
            # Keep screen off until swayidle's resume event triggers
            # (resume triggers on ANY input - mouse move, key press)
            :
        fi
    done
) &
MONITOR_PID=$!

# Wait for hyprlock to finish (user unlocked)
wait $HYPRLOCK_PID

# Cleanup monitor process
kill $MONITOR_PID 2>/dev/null
wait $MONITOR_PID 2>/dev/null

# Ensure screen is on after unlock
hyprctl dispatch dpms on
