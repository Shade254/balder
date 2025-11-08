#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
#  Toggles MacBook keyboard backlight "breathing" effect.
#  Bound to XF86Launch3 (F4) in Hyprland config.
#  Uses apple::kbd_backlight sysfs device.
# ─────────────────────────────────────────────────────────────────────────────

KEY_BRIGHTNESS_PATH="/sys/class/leds/apple::kbd_backlight/brightness"
MAX_BRIGHTNESS=248  # ~48% max - subtle breathing
MIN_BRIGHTNESS=64   # ~12% min - stays visible
SLEEP_TIME=0.15
STEP_SIZE=8
PID_FILE="/tmp/kbd-breathing.pid"

# Check if keyboard backlight exists
if [[ ! -f "$KEY_BRIGHTNESS_PATH" ]]; then
    echo "ERROR: MacBook keyboard backlight not found at $KEY_BRIGHTNESS_PATH"
    exit 1
fi

# Toggle logic: Check if already running FIRST (before acquiring lock)
if [[ -f "$PID_FILE" ]]; then
    PID=$(cat "$PID_FILE")
    # Verify the process is actually running
    if kill -0 "$PID" 2>/dev/null; then
        # Kill the process and wait for it to die
        kill -TERM "$PID" 2>/dev/null
        sleep 0.2  # Give trap time to fire
        # Force kill if still alive
        kill -0 "$PID" 2>/dev/null && kill -9 "$PID" 2>/dev/null
        # Clean up PID file (trap should have done this, but ensure it)
        rm -f "$PID_FILE"
        # Restore normal brightness
        echo 256 > "$KEY_BRIGHTNESS_PATH"
        echo "Breathing stopped"
        exit 0
    else
        # Stale PID file, clean it up
        rm "$PID_FILE"
    fi
fi

# Now acquire exclusive lock to start breathing (prevents multiple instances)
LOCK_FILE="/run/user/$UID/kbd-breathing.lock"
exec 200>"$LOCK_FILE"
flock -n 200 || { echo "Breathing already in progress"; exit 0; }

# Store current PID
echo $$ > "$PID_FILE"

# Cleanup on exit
trap 'rm -f "$PID_FILE"; echo 128 > "$KEY_BRIGHTNESS_PATH"' EXIT INT TERM

# Breathing loop
while true; do
    # Fade in
    for level in $(seq $MIN_BRIGHTNESS $STEP_SIZE $MAX_BRIGHTNESS); do
        echo "$level" > "$KEY_BRIGHTNESS_PATH" 2>/dev/null || exit 1
        sleep "$SLEEP_TIME"
    done

    # Fade out
    for level in $(seq $MAX_BRIGHTNESS -$STEP_SIZE $MIN_BRIGHTNESS); do
        echo "$level" > "$KEY_BRIGHTNESS_PATH" 2>/dev/null || exit 1
        sleep "$SLEEP_TIME"
    done
done
