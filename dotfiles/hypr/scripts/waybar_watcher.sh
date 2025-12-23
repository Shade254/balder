#!/bin/bash
# ──────────────────────────────────────────────────────────────────────────
#  Waybar/Eww Dynamic Switcher (Event-driven wallpaper & widget manager)
#  Switches between Waybar (with windows) and Eww (empty workspace)
#
#  OPTIMIZED: Event-driven with debouncing for smooth transitions
# ──────────────────────────────────────────────────────────────────────────

logfile="/tmp/waybar_watcher.log"

# Wallpapers
wallpaper_with_window="$HOME/.config/hypr/wallpapers/black.png"
wallpaper_without_window="$HOME/.config/hypr/wallpapers/bg_wallpaper.png"

# State tracking
current_mode=""  # "eww" or "waybar"

# Eww widgets (single line for faster parsing)
eww_windows="ascii_decor_frame cpu_ram_storage_bars four_boxes net_bars power-cooling_header_text power_mode_text right_fan_data welcome_text workspace_window_text"

# Debounce settings
DEBOUNCE_MS=150
last_change_time=0
pending_mode=""

log() {
    echo "[$(date '+%H:%M:%S.%3N')] $1" >> "$logfile"
}

# Get current timestamp in milliseconds
now_ms() {
    echo $(($(date +%s%N) / 1000000))
}

# Check if workspace is empty (no mapped windows)
is_workspace_empty() {
    local ws_id=$(hyprctl activeworkspace -j | jq -r '.id')
    local count=$(hyprctl clients -j | jq "[.[] | select(.workspace.id == $ws_id and .mapped == true)] | length")
    [ "$count" -eq 0 ]
}

# Pre-load both wallpapers at startup for instant switching
preload_wallpapers() {
    log "Pre-loading wallpapers..."
    hyprctl hyprpaper preload "$wallpaper_with_window" &>/dev/null
    hyprctl hyprpaper preload "$wallpaper_without_window" &>/dev/null
    log "Wallpapers pre-loaded"
}

# Ensure eww daemon is running
ensure_eww_daemon() {
    if ! pgrep -x eww > /dev/null; then
        log "Starting eww daemon..."
        eww daemon &
        sleep 0.3
    fi
}

# Switch to EWW mode (empty workspace)
switch_to_eww() {
    if [ "$current_mode" = "eww" ]; then
        return
    fi

    log "→ Switching to EWW mode"

    # Get monitor for wallpaper
    local monitor=$(hyprctl monitors -j | jq -r '.[0].name')

    # Do everything in parallel for speed
    {
        # Set wallpaper (already preloaded, so instant)
        hyprctl hyprpaper wallpaper "$monitor,$wallpaper_without_window" &>/dev/null
    } &

    {
        # Kill waybar
        pkill -x waybar 2>/dev/null
    } &

    {
        # Open eww widgets
        eww open-many $eww_windows &>/dev/null
    } &

    # Wait for all background jobs
    wait

    current_mode="eww"
    log "✓ EWW mode active"
}

# Switch to Waybar mode (windows present)
switch_to_waybar() {
    if [ "$current_mode" = "waybar" ]; then
        return
    fi

    log "→ Switching to Waybar mode"

    # Get monitor for wallpaper
    local monitor=$(hyprctl monitors -j | jq -r '.[0].name')

    # Do everything in parallel for speed
    {
        # Set wallpaper (already preloaded, so instant)
        hyprctl hyprpaper wallpaper "$monitor,$wallpaper_with_window" &>/dev/null
    } &

    {
        # Close eww widgets
        eww close-all &>/dev/null
    } &

    {
        # Start waybar (only if not running)
        if ! pgrep -x waybar > /dev/null; then
            waybar &>/dev/null &
        fi
    } &

    # Wait for all background jobs
    wait

    current_mode="waybar"
    log "✓ Waybar mode active"
}

# Apply the appropriate mode based on workspace state
apply_mode() {
    if is_workspace_empty; then
        switch_to_eww
    else
        switch_to_waybar
    fi
}

# Debounced mode change - waits for state to stabilize
debounced_apply() {
    local now=$(now_ms)
    local target_mode="waybar"

    if is_workspace_empty; then
        target_mode="eww"
    fi

    # If mode hasn't changed, nothing to do
    if [ "$target_mode" = "$current_mode" ]; then
        pending_mode=""
        return
    fi

    # If this is a new pending change, record it
    if [ "$pending_mode" != "$target_mode" ]; then
        pending_mode="$target_mode"
        last_change_time=$now
        log "Pending mode change to: $target_mode"
        return
    fi

    # Check if debounce time has passed
    local elapsed=$((now - last_change_time))
    if [ $elapsed -ge $DEBOUNCE_MS ]; then
        log "Debounce complete ($elapsed ms), applying: $target_mode"
        if [ "$target_mode" = "eww" ]; then
            switch_to_eww
        else
            switch_to_waybar
        fi
        pending_mode=""
    fi
}

# ─────────────────────────────────────────────────────────────────────────────
# MAIN
# ─────────────────────────────────────────────────────────────────────────────

log "========== Waybar Watcher Started =========="

# Start hyprpaper if needed
if ! pgrep -x hyprpaper > /dev/null; then
    log "Starting hyprpaper..."
    hyprpaper &
    sleep 0.5
fi

# Pre-load wallpapers for instant switching
preload_wallpapers

# Ensure eww daemon is ready
ensure_eww_daemon

# Set initial state
apply_mode

# Event-driven loop using Hyprland socket
log "Listening for Hyprland events..."

# Use socat to listen to Hyprland events
socat -u "UNIX-CONNECT:/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" - 2>/dev/null | while read -r line; do
    # Filter for relevant events
    case "$line" in
        workspace*|activewindow*|closewindow*|openwindow*|movewindow*|fullscreen*)
            log "Event: ${line:0:50}..."
            debounced_apply
            ;;
    esac
done &

SOCAT_PID=$!

# Fallback: also poll occasionally in case events are missed
# This runs less frequently since events handle most changes
while true; do
    sleep 0.1
    debounced_apply
done

# Cleanup on exit
trap "kill $SOCAT_PID 2>/dev/null" EXIT
