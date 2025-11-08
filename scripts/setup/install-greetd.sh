#!/bin/bash
# ──────────────────────────────────────────────────────────────────────────
#  greetd + tuigreet Installation Script
#  Minimal TUI login manager for Hyprland
# ──────────────────────────────────────────────────────────────────────────

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}  greetd + tuigreet Installation${NC}"
echo -e "${CYAN}  Minimal Terminal Login Manager${NC}"
echo -e "${CYAN}════════════════════════════════════════════════════════${NC}"
echo ""

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo -e "${RED}ERROR: Don't run this script as root!${NC}"
    echo -e "Run it as your normal user. It will ask for sudo when needed."
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}[STEP 1/5]${NC} Installing greetd and tuigreet..."
echo ""

# Install packages
if sudo pacman -S --needed greetd greetd-tuigreet; then
    echo -e "${GREEN}✓ Packages installed${NC}"
else
    echo -e "${RED}✗ Failed to install packages${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}[STEP 2/5]${NC} Configuring greetd..."
echo ""

# Backup existing config if it exists
if [ -f /etc/greetd/config.toml ]; then
    BACKUP="/etc/greetd/config.toml.backup-$(date +%Y%m%d-%H%M%S)"
    echo -e "${YELLOW}[WARNING]${NC} Existing greetd config found"
    if sudo cp /etc/greetd/config.toml "$BACKUP"; then
        echo -e "${GREEN}✓ Backed up to: $BACKUP${NC}"
    fi
fi

# Install greetd config
if sudo cp "$SCRIPT_DIR/dotfiles/greetd/config.toml" /etc/greetd/config.toml; then
    echo -e "${GREEN}✓ greetd config installed${NC}"
else
    echo -e "${RED}✗ Failed to install greetd config${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}[STEP 3/5]${NC} Setting up greetd user and permissions..."
echo ""

# Create greetd user if it doesn't exist (pacman should do this, but just in case)
if ! id -u greeter &>/dev/null; then
    echo -e "${YELLOW}Creating greeter user...${NC}"
    sudo useradd -M -G video greeter
    sudo passwd -d greeter
fi

# Ensure greeter user is in video group (needed for display access)
if sudo usermod -aG video greeter; then
    echo -e "${GREEN}✓ greeter user configured${NC}"
fi

echo ""
echo -e "${BLUE}[STEP 4/5]${NC} Switching from SDDM to greetd..."
echo ""

# Check if SDDM is currently enabled
if systemctl is-enabled sddm.service &>/dev/null; then
    echo -e "${YELLOW}Disabling SDDM service...${NC}"
    if sudo systemctl disable sddm.service; then
        echo -e "${GREEN}✓ SDDM disabled${NC}"
    fi
fi

# Enable greetd
echo -e "${YELLOW}Enabling greetd service...${NC}"
if sudo systemctl enable greetd.service; then
    echo -e "${GREEN}✓ greetd service enabled${NC}"
else
    echo -e "${RED}✗ Failed to enable greetd${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}[STEP 5/5]${NC} Verifying installation..."
echo ""

# Check if service is enabled
if systemctl is-enabled greetd.service &>/dev/null; then
    echo -e "${GREEN}✓ greetd is enabled and will start on boot${NC}"
else
    echo -e "${RED}✗ greetd service not enabled properly${NC}"
    exit 1
fi

# Check config exists
if [ -f /etc/greetd/config.toml ]; then
    echo -e "${GREEN}✓ Configuration file exists${NC}"
else
    echo -e "${RED}✗ Configuration file missing${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  Installation Complete!${NC}"
echo -e "${GREEN}════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${CYAN}What was installed:${NC}"
echo -e "  ✓ greetd:        Minimal login manager daemon"
echo -e "  ✓ tuigreet:      TUI greeter with Hyprland theme"
echo -e "  ✓ Config:        /etc/greetd/config.toml"
echo -e "  ✓ Service:       greetd.service (enabled)"
echo ""
echo -e "${YELLOW}What changed:${NC}"
echo -e "  • SDDM service disabled (not removed yet)"
echo -e "  • greetd service enabled"
echo -e "  • Next boot will show tuigreet TUI login"
echo ""
echo -e "${CYAN}Next steps:${NC}"
echo -e "  1. Reboot to see the new login screen"
echo -e "  2. After confirming it works, run: ./remove-sddm.sh"
echo -e "  3. Install hyprlock for screen locking"
echo ""
echo -e "${YELLOW}To revert back to SDDM (if needed):${NC}"
echo -e "  sudo systemctl disable greetd.service"
echo -e "  sudo systemctl enable sddm.service"
echo -e "  sudo reboot"
echo ""
echo -e "${GREEN}🎨 Your minimal TUI login experience is ready!${NC}"
