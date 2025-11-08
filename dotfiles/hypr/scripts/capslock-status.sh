#!/bin/bash
# Check if CAPSLOCK is on and display warning (Wayland compatible)

# Wayland method using hyprctl
if hyprctl devices -j 2>/dev/null | grep -q '"capsLock":true'; then
    echo "⚠ CAPS LOCK IS ON"
else
    echo ""
fi
