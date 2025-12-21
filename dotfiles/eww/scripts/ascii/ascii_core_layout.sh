#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
#  ascii_core_layout.sh
#  Gets the current Hyprland workspace ID and writes a small ASCII frame
#  to /tmp/core_layout.txt with Cyrillic letters for workspaces 1-4.
#  Example output (written to /tmp/core_layout.txt):
#                   ─┐     ┌─
#                    [  Б  ]
#                   ─┘     └─
# ─────────────────────────────────────────────────────────────────────────────

ws=$(hyprctl activeworkspace -j | jq -r '.id')

# Map workspace numbers to Cyrillic letters (1-4), fallback to numbers for 5+
case $ws in
  1) symbol="А" ;;
  2) symbol="Б" ;;
  3) symbol="В" ;;
  4) symbol="Г" ;;
  *) symbol="$ws" ;;
esac

cat <<EOF > /tmp/core_layout.txt
                 ─┐     ┌─
                  [  $symbol  ]
                 ─┘     └─
EOF
