#!/bin/bash
# ──────────────────────────────────────────────────────────────────────────
#  Remove SDDM (after greetd is working)
#  Clean up old display manager
# ──────────────────────────────────────────────────────────────────────────

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}  SDDM Removal Script${NC}"
echo -e "${YELLOW}════════════════════════════════════════════════════════${NC}"
echo ""

# Safety check - make sure greetd is enabled
if ! systemctl is-enabled greetd.service &>/dev/null; then
    echo -e "${RED}ERROR: greetd is not enabled!${NC}"
    echo -e "${RED}Don't remove SDDM until greetd is working!${NC}"
    echo ""
    echo -e "First:"
    echo -e "  1. Run ./install-greetd.sh"
    echo -e "  2. Reboot and verify login works"
    echo -e "  3. Then run this script"
    exit 1
fi

echo -e "${BLUE}✓ greetd is enabled - safe to remove SDDM${NC}"
echo ""

# Check if SDDM is installed
if ! pacman -Q sddm &>/dev/null; then
    echo -e "${YELLOW}SDDM is not installed - nothing to remove!${NC}"
    exit 0
fi

echo -e "${YELLOW}This will:${NC}"
echo -e "  • Remove SDDM package and Maya theme"
echo -e "  • Clean up SDDM configs"
echo -e "  • Remove SDDM dotfiles from repository"
echo ""
echo -e "${RED}Make sure greetd login is working before continuing!${NC}"
echo ""
read -p "Continue? (y/N): " confirm

if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
    echo -e "${BLUE}Cancelled.${NC}"
    exit 0
fi

echo ""
echo -e "${BLUE}[1/3]${NC} Removing SDDM package..."
if sudo pacman -Rns sddm; then
    echo -e "${GREEN}✓ SDDM removed${NC}"
else
    echo -e "${RED}✗ Failed to remove SDDM${NC}"
    echo -e "${YELLOW}You may need to remove it manually${NC}"
fi

echo ""
echo -e "${BLUE}[2/3]${NC} Cleaning up config files..."

# Remove SDDM configs
if [ -d /etc/sddm.conf.d ]; then
    echo -e "${YELLOW}Removing /etc/sddm.conf.d/${NC}"
    sudo rm -rf /etc/sddm.conf.d/
    echo -e "${GREEN}✓ Config directory removed${NC}"
fi

echo ""
echo -e "${BLUE}[3/3]${NC} Removing SDDM dotfiles from repository..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -d "$SCRIPT_DIR/dotfiles/sddm" ]; then
    rm -rf "$SCRIPT_DIR/dotfiles/sddm"
    echo -e "${GREEN}✓ dotfiles/sddm/ removed${NC}"
fi

if [ -f "$SCRIPT_DIR/install-sddm.sh" ]; then
    rm "$SCRIPT_DIR/install-sddm.sh"
    echo -e "${GREEN}✓ install-sddm.sh removed${NC}"
fi

echo ""
echo -e "${GREEN}════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  SDDM Successfully Removed!${NC}"
echo -e "${GREEN}════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${CYAN}You're now using:${NC}"
echo -e "  • Login: greetd + tuigreet (minimal TUI)"
echo -e "  • Lock:  hyprlock (matching aesthetic)"
echo ""
echo -e "${GREEN}Clean, minimal, unified! 🎨${NC}"
