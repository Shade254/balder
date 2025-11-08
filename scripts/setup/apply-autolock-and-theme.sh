#!/bin/bash
# ──────────────────────────────────────────────────────────────────────────
#  °˖* ૮( • ᴗ ｡)っ🍸 Auto-lock + Themed Login Setup Script
#  Applies swayidle auto-lock and enhanced tuigreet theme
# ──────────────────────────────────────────────────────────────────────────

set -e  # Exit on error

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}"
cat << "EOF"
🔒 Auto-lock + Themed Login Setup
EOF
echo -e "${NC}"

# Check if swayidle is installed
echo -e "${BLUE}[1/4]${NC} Checking swayidle installation..."
if ! command -v swayidle &> /dev/null; then
    echo -e "${YELLOW}swayidle not found. Installing...${NC}"
    sudo pacman -S --noconfirm swayidle
    echo -e "${GREEN}✓ swayidle installed${NC}"
else
    echo -e "${GREEN}✓ swayidle already installed${NC}"
fi

# Deploy Hyprland config (with swayidle)
echo ""
echo -e "${BLUE}[2/4]${NC} Deploying Hyprland config with auto-lock..."
./deploy.sh

echo ""
echo -e "${BLUE}[3/4]${NC} Updating greetd theme to match Alacritty..."
sudo cp dotfiles/greetd/config.toml /etc/greetd/config.toml
echo -e "${GREEN}✓ greetd theme updated${NC}"

# Reload Hyprland
echo ""
echo -e "${BLUE}[4/4]${NC} Reloading Hyprland configuration..."
if command -v hyprctl &> /dev/null; then
    hyprctl reload &> /dev/null && \
        echo -e "${GREEN}✓ Hyprland reloaded${NC}" || \
        echo -e "${YELLOW}⚠ Manual reload may be needed${NC}"
fi

# Summary
echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✓ Setup Complete!${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${CYAN}Auto-lock Settings:${NC}"
echo "  • Lock after 5 minutes idle (300s)"
echo "  • Screen off after 10 minutes idle (600s)"
echo "  • Auto-lock before suspend/sleep"
echo ""
echo -e "${CYAN}Login Screen Theme:${NC}"
echo "  • Colors: Light cyan + Blue accents (matches Alacritty)"
echo "  • Background: Dark (#282c34)"
echo "  • Asterisks enabled for password"
echo "  • Username/session remembered"
echo ""
echo -e "${CYAN}What's Next:${NC}"
echo "  1. Test manual lock: ${GREEN}Super + L${NC} or ${GREEN}hyprlock${NC}"
echo "  2. Wait 5 minutes to test auto-lock"
echo "  3. Reboot to see new login theme: ${GREEN}sudo reboot${NC}"
echo ""
echo -e "${CYAN}Customization:${NC}"
echo "  • See ${BLUE}dotfiles/greetd/THEME_CUSTOMIZATION.md${NC} for theme options"
echo "  • Edit ${BLUE}dotfiles/greetd/config.toml${NC} to change colors"
echo "  • Edit ${BLUE}dotfiles/hypr/hyprland.conf${NC} (line 36) to adjust timeouts"
echo ""
echo -e "${GREEN}🍸 Enjoy your unified aesthetic experience!${NC}"
