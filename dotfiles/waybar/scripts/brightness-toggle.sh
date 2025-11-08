#!/bin/bash
# ── brightness-toggle.sh ─────────────────────────────
# Description: Cycle screen brightness between 30%, 60%, and 100%
# Usage: Waybar `custom/brightness` on-click
# Dependencies: brightnessctl
# ─────────────────────────────────────────────────────

current=$(brightnessctl --device='acpi_video0' get)
max=$(brightnessctl --device='acpi_video0' max)
percent=$((current * 100 / max))

if [ "$percent" -lt 45 ]; then
  brightnessctl --device='acpi_video0' set 60%
elif [ "$percent" -lt 85 ]; then
  brightnessctl --device='acpi_video0' set 100%
else
  brightnessctl --device='acpi_video0' set 30%
fi

