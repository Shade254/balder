#!/bin/bash
# ──────────────────────────────────────────────────────────────────────────
#  SDDM Maya Theme Installation Script
#  Install SDDM configuration with Hyprland-matching colors
# ──────────────────────────────────────────────────────────────────────────

set -e  # Exit on error

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$SCRIPT_DIR/dotfiles"

echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  SDDM Maya Theme Installation${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"
echo ""

# Check if running as root (don't run script as root, we'll use sudo for specific commands)
if [ "$EUID" -eq 0 ]; then
    echo -e "${RED}ERROR: Don't run this script as root!${NC}"
    echo -e "Run it as your normal user. It will ask for sudo when needed."
    exit 1
fi

# Check if SDDM is installed
if ! command -v sddm &> /dev/null; then
    echo -e "${RED}ERROR: SDDM is not installed!${NC}"
    echo -e "Install with: sudo pacman -S sddm"
    exit 1
fi

echo -e "${BLUE}[INFO]${NC} Installing SDDM configuration..."
echo ""

# Create SDDM config directory
echo -e "${BLUE}[INFO]${NC} Creating /etc/sddm.conf.d/ directory..."
if sudo mkdir -p /etc/sddm.conf.d/; then
    echo -e "${GREEN}[SUCCESS]${NC} Directory created"
else
    echo -e "${RED}[ERROR]${NC} Failed to create directory"
    exit 1
fi

# Copy main SDDM config
echo -e "${BLUE}[INFO]${NC} Installing SDDM configuration..."
if sudo cp "$DOTFILES_DIR/sddm/sddm.conf" /etc/sddm.conf.d/sddm.conf; then
    echo -e "${GREEN}[SUCCESS]${NC} Config installed to /etc/sddm.conf.d/sddm.conf"
else
    echo -e "${RED}[ERROR]${NC} Failed to copy SDDM config"
    exit 1
fi

# Backup existing Maya theme config if it exists
if [ -f /usr/share/sddm/themes/maya/theme.conf ]; then
    BACKUP_FILE="/usr/share/sddm/themes/maya/theme.conf.backup-$(date +%Y%m%d-%H%M%S)"
    echo -e "${YELLOW}[WARNING]${NC} Existing Maya theme config found"
    if sudo cp /usr/share/sddm/themes/maya/theme.conf "$BACKUP_FILE"; then
        echo -e "${GREEN}[SUCCESS]${NC} Backed up to: $BACKUP_FILE"
    fi
fi

# Copy Maya theme config
echo -e "${BLUE}[INFO]${NC} Installing Maya theme colors (matching Hyprland aesthetic)..."
if sudo cp "$DOTFILES_DIR/sddm/theme.conf" /usr/share/sddm/themes/maya/theme.conf; then
    echo -e "${GREEN}[SUCCESS]${NC} Maya theme colors installed"
else
    echo -e "${RED}[ERROR]${NC} Failed to copy Maya theme config"
    exit 1
fi

echo ""
echo -e "${GREEN}════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  Installation Complete!${NC}"
echo -e "${GREEN}════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${BLUE}What was installed:${NC}"
echo -e "  ✓ SDDM config:    /etc/sddm.conf.d/sddm.conf"
echo -e "  ✓ Maya theme:     /usr/share/sddm/themes/maya/theme.conf"
echo -e "  ✓ Theme enabled:  Maya with Hyprland-matching colors"
echo ""
echo -e "${YELLOW}Preview the theme (in a window):${NC}"
echo -e "  sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/maya/"
echo ""
echo -e "${YELLOW}Apply changes:${NC}"
echo -e "  Option 1: Logout (to see the login screen)"
echo -e "  Option 2: Reboot"
echo -e "  Option 3: Restart SDDM (will logout): sudo systemctl restart sddm"
echo ""
echo -e "${GREEN}🎨 Your login screen will now match your Hyprland aesthetic!${NC}"
