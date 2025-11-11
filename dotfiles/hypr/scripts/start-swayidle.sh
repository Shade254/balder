#!/usr/bin/env bash
# Swayidle launcher with singleton enforcement
# Ensures only one instance runs at a time

# Kill any existing swayidle instances
pkill swayidle

# Wait a moment for processes to terminate
sleep 0.5

# Start swayidle with idle lock configuration
# Strategy: Let hyprlock handle DPMS internally via its config
# swayidle just triggers the lock, hyprlock manages screen power
exec swayidle -w \
    timeout 300 'hyprlock' \
    before-sleep 'hyprlock'
