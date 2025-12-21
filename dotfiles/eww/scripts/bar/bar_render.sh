#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
#  Converts a numeric percentage (0–100) into an ASCII block bar.
#  Uses half-block (▓) for extra precision when remainder >= 50%.
#  Example:
#      ./bar_render.sh 73
#      ██████████████▓░░░░░  (14 full + 1 half + 5 empty)
# ─────────────────────────────────────────────────────────────────────────────

usage=$1  # pass percentage as the first argument
full="█"
half="▓"
empty="░"

blocks=20

# Multiply by 10 to get one decimal place precision using integer math
# e.g., 73% of 20 blocks = 14.6 blocks → 146 in tenths
filled_tenths=$(( usage * blocks * 10 / 100 ))
filled_full=$(( filled_tenths / 10 ))
remainder=$(( filled_tenths % 10 ))

bar=""

for ((i=0; i<blocks; i++)); do
  if [ $i -lt $filled_full ]; then
    bar+="$full"
  elif [ $i -eq $filled_full ] && [ $remainder -ge 5 ]; then
    bar+="$half"
  else
    bar+="$empty"
  fi
done

echo "$bar"
