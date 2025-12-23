#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
#  net_upload_bar.sh
#  Renders a vertical bar (10 lines) from a given percentage (0–100).
#  Uses Pango markup for tight line spacing.
#
#  Usage: ./net_upload_bar.sh <percent>
#  Example: ./net_upload_bar.sh 73
# ─────────────────────────────────────────────────────────────────────────────

percent=$1
lines=10

# Cap 0–100
if [ "$percent" -gt 100 ]; then percent=100; fi
if [ "$percent" -lt 0 ]; then percent=0; fi

# Scale percentage into rows (round up)
filled=$(( (percent * lines + 99) / 100 ))

# Always show at least one block if >0
if (( percent > 0 && filled == 0 )); then
  filled=1
fi

# Build output with Pango markup for tight line spacing
# Use &#10; for newlines to preserve markup through defpoll
output='<span line_height="0.6">'
for ((i=0; i<lines; i++)); do
  row=$((lines - i))  # count from top
  if (( row <= filled )); then
    if (( row == filled )); then
      output+="╽"
    else
      output+="█"
    fi
  else
    output+="│"
  fi
  # Add XML newline entity except for last line
  if (( i < lines - 1 )); then
    output+="&#10;"
  fi
done
output+='</span>'

printf '%s' "$output"

