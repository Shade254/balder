#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
#  Script: sys_fan_large.sh
#  Purpose: Displays large ASCII fan art animation (synchronized between fans)
#
#  Design: Single 2-blade propeller rotating through 4 positions (| / - \)
#  Synchronization: Uses time-based frame selection so both fans always match.
#  Output: Pango markup with line_height control for tight vertical spacing.
#
#  Reference: Classic terminal spinner pattern from Rosetta Code
#  Example:
#      ./sys_fan_large.sh left
#      ./sys_fan_large.sh right
# ─────────────────────────────────────────────────────────────────────────────

fan="$1"

# Get RPM - T2 Mac uses fan1 (left) and fan2 (right)
if [ "$fan" = "left" ]; then
  rpm=$(sensors | grep -E '^fan1:' | awk '{print $2}')
elif [ "$fan" = "right" ]; then
  rpm=$(sensors | grep -E '^fan2:' | awk '{print $2}')
else
  rpm=0
fi
[ -z "$rpm" ] && rpm=0

# Output with Pango markup for tight line spacing
# Using &#10; for newlines within the span
output_frame() {
  local line1="$1"
  local line2="$2"
  local line3="$3"
  local line4="$4"
  local line5="$5"
  echo "<span line_height=\"0.85\">${line1}&#10;${line2}&#10;${line3}&#10;${line4}&#10;${line5}</span>"
}

# If fan is stopped, show static fan (vertical blade)
if [ "$rpm" -eq 0 ]; then
  output_frame "╭─────╮" "│  │  │" "│  ●  │" "│  │  │" "╰─────╯"
  exit 0
fi

# TIME-BASED SYNC: Frame changes every ~300ms (matches eww poll interval)
deciseconds=$(( $(date +%s%N) / 100000000 ))
index=$(( (deciseconds / 3) % 4 ))

# 2-blade propeller rotating: | → / → ─ → \ → |
case $index in
  0)
    output_frame "╭─────╮" "│  │  │" "│  ●  │" "│  │  │" "╰─────╯"
    ;;
  1)
    output_frame "╭─────╮" "│   ╱ │" "│  ●  │" "│ ╱   │" "╰─────╯"
    ;;
  2)
    output_frame "╭─────╮" "│     │" "│──●──│" "│     │" "╰─────╯"
    ;;
  3)
    output_frame "╭─────╮" "│ ╲   │" "│  ●  │" "│   ╲ │" "╰─────╯"
    ;;
esac
