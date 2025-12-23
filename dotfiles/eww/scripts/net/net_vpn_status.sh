#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
#  net_vpn_status.sh
#  Wrapper for net_vpn.sh - outputs just the status text.
#  Kept for backwards compatibility.
# ─────────────────────────────────────────────────────────────────────────────

# Use the main script and extract just the text part
bash "$(dirname "$0")/net_vpn.sh" | cut -d'|' -f1
