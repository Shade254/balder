#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────────────────
#  Balder Screenshot Script
#  Powered by grim + slurp for Hyprland/Wayland
# ──────────────────────────────────────────────────────────────────────────

set -euo pipefail

# Configuration
SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
TIMESTAMP=$(date +'%Y-%m-%d-%H%M%S')

# Ensure screenshot directory exists
mkdir -p "$SCREENSHOT_DIR"

# Screenshot modes
MODE="${1:-area}"

screenshot_full() {
    local filename="$SCREENSHOT_DIR/screenshot-full-$TIMESTAMP.png"
    grim "$filename"
    wl-copy < "$filename"
    notify-send -u normal -i "$filename" "Screenshot Captured" "Full screen saved to Screenshots/"
    echo "$filename"
}

screenshot_area() {
    local filename="$SCREENSHOT_DIR/screenshot-area-$TIMESTAMP.png"
    local geometry

    # Use slurp to select area, exit if cancelled
    if geometry=$(slurp 2>/dev/null); then
        grim -g "$geometry" "$filename"
        wl-copy < "$filename"
        notify-send -u normal -i "$filename" "Screenshot Captured" "Area selection saved to Screenshots/"
        echo "$filename"
    else
        notify-send -u low "Screenshot Cancelled" "Area selection was cancelled"
        exit 0
    fi
}

screenshot_window() {
    # Get the currently focused window's geometry using hyprctl
    local geometry
    geometry=$(hyprctl -j activewindow | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')

    if [[ -n "$geometry" && "$geometry" != "null" ]]; then
        local filename="$SCREENSHOT_DIR/screenshot-window-$TIMESTAMP.png"
        grim -g "$geometry" "$filename"
        wl-copy < "$filename"
        notify-send -u normal -i "$filename" "Screenshot Captured" "Active window saved to Screenshots/"
        echo "$filename"
    else
        notify-send -u critical "Screenshot Failed" "Could not determine active window"
        exit 1
    fi
}

# Main execution
case "$MODE" in
    full)
        screenshot_full
        ;;
    area)
        screenshot_area
        ;;
    window)
        screenshot_window
        ;;
    *)
        echo "Usage: $0 {full|area|window}"
        echo "  full   - Capture entire screen"
        echo "  area   - Select area to capture (default)"
        echo "  window - Capture active window"
        exit 1
        ;;
esac
