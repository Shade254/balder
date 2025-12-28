#!/bin/bash
# ── mic.sh ───────────────────────────────────────────────────
# Description: Shows microphone mute/unmute status with icon
# Usage: Called by Waybar `custom/microphone` module every 1s
# Dependencies: pactl (PulseAudio / PipeWire)
# ─────────────────────────────────────────────────────────────

if pactl get-source-mute @DEFAULT_SOURCE@ | grep -q 'yes'; then
  # Muted → mic-off icon with "muted" class for CSS styling
  echo '{"text":"[ 󰍭 ]","tooltip":"Microphone OFF","class":"muted"}'
else
  # Active → mic-on icon with "active" class for CSS styling
  echo '{"text":"[ 󰍬 ]","tooltip":"Microphone ON","class":"active"}'
fi
