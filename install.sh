#!/bin/bash
# ──────────────────────────────────────────────────────────────────────────
#  °˖* ૮( • ᴗ ｡)っ🍸 Balder Dotfiles - Modular Installer
#  Balder v1.0 - MacBook Pro 2018 Touchbar Edition
# ──────────────────────────────────────────────────────────────────────────
#
#  Install dependencies for your Hyprland rice, modularly!
#
#  Usage:
#    ./install.sh              # Interactive mode
#    ./install.sh --all        # Install everything
#    ./install.sh --core       # Minimal Hyprland setup
#    ./install.sh --waybar     # Just Waybar dependencies
#    ./install.sh --terminal   # Terminal tools
#    ./install.sh --appearance # Theming and visual tools
#    ./install.sh --extras     # Optional widgets (Eww, Cava, etc.)
#
# ──────────────────────────────────────────────────────────────────────────

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/scripts/utils/logging.sh"

# Banner
show_banner() {
    echo -e "${CYAN}"
    cat << "EOF"
     ) ) )                     ) ) )
   ( ( (                      ( ( (
 ) ) )                       ) ) )
(~~~~~~~~~)                 (~~~~~~~~~)
 |   А   |                   |   Б   |
 |       |                   |       |
 I      _._                  I       _._
 I    /'   `\                I     /'   `\
 I   |   N   |               I    |   N   |
 f   |   |~~~~~~~~~~~~~~|    f    |    |~~~~~~~~~~~~~~|
.'    |   ||~~~~~~~~|    |  .'     |    | |~~~~~~~~|   |
'______|___||__###___|____|/'_______|____|_|__###___|___|

🍸 Balder Dotfiles - Modular Installer
EOF
    echo -e "${NC}"
}

# Show help
show_help() {
    cat << EOF
Balder Dotfiles Modular Installer

USAGE:
    ./install.sh [OPTIONS]

OPTIONS:
    --all           Install all components
    --core          Install core Hyprland packages
    --waybar        Install Waybar and status bar dependencies
    --terminal      Install terminal emulator and shell tools
    --appearance    Install theming, fonts, and visual tools
    --extras        Install optional widgets and extras
    --help          Show this help message

INTERACTIVE MODE:
    Run without arguments for interactive component selection

EXAMPLES:
    ./install.sh --all                    # Full installation
    ./install.sh --core --waybar          # Minimal functional setup
    ./install.sh --waybar                 # Just Waybar deps (for forking)

EOF
}

# Interactive mode
interactive_install() {
    log_section "Interactive Installation"

    echo "Select components to install (y/n):"
    echo ""

    read -p "$(echo -e ${CYAN}[1/5]${NC}) Core Hyprland packages? (y/n): " install_core_choice
    read -p "$(echo -e ${CYAN}[2/5]${NC}) Waybar and status bar? (y/n): " install_waybar_choice
    read -p "$(echo -e ${CYAN}[3/5]${NC}) Terminal and shell tools? (y/n): " install_terminal_choice
    read -p "$(echo -e ${CYAN}[4/5]${NC}) Appearance and theming? (y/n): " install_appearance_choice
    read -p "$(echo -e ${CYAN}[5/5]${NC}) Extra widgets (Eww, Cava)? (y/n): " install_extras_choice

    echo ""

    [[ "$install_core_choice" =~ ^[Yy]$ ]] && source "$SCRIPT_DIR/scripts/install/core.sh" && install_core
    [[ "$install_waybar_choice" =~ ^[Yy]$ ]] && source "$SCRIPT_DIR/scripts/install/waybar.sh" && install_waybar
    [[ "$install_terminal_choice" =~ ^[Yy]$ ]] && source "$SCRIPT_DIR/scripts/install/terminal.sh" && install_terminal
    [[ "$install_appearance_choice" =~ ^[Yy]$ ]] && source "$SCRIPT_DIR/scripts/install/appearance.sh" && install_appearance
    [[ "$install_extras_choice" =~ ^[Yy]$ ]] && source "$SCRIPT_DIR/scripts/install/extras.sh" && install_extras
}

# Main installation logic
main() {
    show_banner

    # Check if running on Arch Linux
    if [ ! -f /etc/arch-release ]; then
        log_warning "This installer is designed for Arch Linux"
        log_info "You may need to adapt package names for your distribution"
        read -p "Continue anyway? (y/n): " continue_choice
        [[ ! "$continue_choice" =~ ^[Yy]$ ]] && exit 0
    fi

    # Check for pacman
    if ! command_exists pacman; then
        log_error "pacman not found. This script requires Arch Linux or an Arch-based distro"
        exit 1
    fi

    # Parse arguments
    if [ $# -eq 0 ]; then
        # No arguments - interactive mode
        interactive_install
    else
        # Process command-line arguments
        while [ $# -gt 0 ]; do
            case "$1" in
                --help|-h)
                    show_help
                    exit 0
                    ;;
                --all)
                    source "$SCRIPT_DIR/scripts/install/core.sh" && install_core
                    source "$SCRIPT_DIR/scripts/install/waybar.sh" && install_waybar
                    source "$SCRIPT_DIR/scripts/install/terminal.sh" && install_terminal
                    source "$SCRIPT_DIR/scripts/install/appearance.sh" && install_appearance
                    source "$SCRIPT_DIR/scripts/install/extras.sh" && install_extras
                    ;;
                --core)
                    source "$SCRIPT_DIR/scripts/install/core.sh" && install_core
                    ;;
                --waybar)
                    source "$SCRIPT_DIR/scripts/install/waybar.sh" && install_waybar
                    ;;
                --terminal)
                    source "$SCRIPT_DIR/scripts/install/terminal.sh" && install_terminal
                    ;;
                --appearance)
                    source "$SCRIPT_DIR/scripts/install/appearance.sh" && install_appearance
                    ;;
                --extras)
                    source "$SCRIPT_DIR/scripts/install/extras.sh" && install_extras
                    ;;
                *)
                    log_error "Unknown option: $1"
                    show_help
                    exit 1
                    ;;
            esac
            shift
        done
    fi

    echo ""
    log_section "Installation Complete!"

    log_success "Dependencies installed successfully!"
    echo ""
    log_info "Next steps:"
    echo "  1. Run ./deploy.sh to deploy your dotfiles"
    echo "  2. Reboot or log out and log back in"
    echo "  3. Enjoy your Hyprland rice!"
    echo ""
    echo -e "${GREEN}🍸 Welcome to Balder!${NC}"
}

# Run main
main "$@"
