#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
#  Toggles MacBook keyboard backlight "breathing" effect.
#  Bound to XF86Launch3 (F4) in Hyprland config.
#  Uses apple::kbd_backlight sysfs device.
# ─────────────────────────────────────────────────────────────────────────────

KEY_BRIGHTNESS_PATH="/sys/class/leds/apple::kbd_backlight/brightness"
MAX_BRIGHTNESS=512
MIN_BRIGHTNESS=1
SLEEP_TIME=0.2
PID_FILE="/tmp/kbd-breathing.pid"

# Check if keyboard backlight exists
if [[ ! -f "$KEY_BRIGHTNESS_PATH" ]]; then
    echo "ERROR: MacBook keyboard backlight not found at $KEY_BRIGHTNESS_PATH"
    exit 1
fi

# If script already running, stop it (toggle off)
if [[ -f "$PID_FILE" ]]; then
    PID=$(cat "$PID_FILE")
    kill "$PID" 2>/dev/null
    rm "$PID_FILE"
    # Restore normal brightness
    echo 128 > "$KEY_BRIGHTNESS_PATH"
    exit 0
fi

# Store current PID
echo $$ > "$PID_FILE"

# Cleanup on exit
trap 'rm -f "$PID_FILE"; echo 128 > "$KEY_BRIGHTNESS_PATH"' EXIT INT TERM

# Breathing loop
while true; do
    # Fade in
    for level in $(seq $MIN_BRIGHTNESS $MAX_BRIGHTNESS); do
        echo "$level" > "$KEY_BRIGHTNESS_PATH" 2>/dev/null || exit 1
        sleep "$SLEEP_TIME"
    done

    # Fade out
    for level in $(seq $MAX_BRIGHTNESS -1 $MIN_BRIGHTNESS); do
        echo "$level" > "$KEY_BRIGHTNESS_PATH" 2>/dev/null || exit 1
        sleep "$SLEEP_TIME"
    done
done
