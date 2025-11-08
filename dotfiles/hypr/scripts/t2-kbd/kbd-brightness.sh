#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
#  Stops keyboard breathing (if running) and adjusts brightness manually.
#  When you press brightness keys, breathing stops and you take manual control.
# ─────────────────────────────────────────────────────────────────────────────

PID_FILE="/tmp/kbd-breathing.pid"
KEY_BRIGHTNESS_PATH="/sys/class/leds/apple::kbd_backlight/brightness"

# Stop breathing if it's running
if [[ -f "$PID_FILE" ]]; then
    PID=$(cat "$PID_FILE")
    # Verify the process is actually running
    if kill -0 "$PID" 2>/dev/null; then
        # Kill and wait for it to die
        kill -TERM "$PID" 2>/dev/null
        sleep 0.2
        # Force kill if still alive
        kill -0 "$PID" 2>/dev/null && kill -9 "$PID" 2>/dev/null
        rm -f "$PID_FILE"
    else
        # Stale PID file, clean it up
        rm -f "$PID_FILE"
    fi
fi

# Now adjust brightness based on argument
case "$1" in
    up)
        brightnessctl --device='apple::kbd_backlight' set 5%+
        ;;
    down)
        brightnessctl --device='apple::kbd_backlight' set 5%-
        ;;
    *)
        echo "Usage: $0 {up|down}"
        exit 1
        ;;
esac
