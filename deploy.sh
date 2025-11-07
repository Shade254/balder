#!/bin/bash
# ──────────────────────────────────────────────────────────────────────────
#  °˖* ૮( • ᴗ ｡)っ🍸 Balder Dotfiles Deployment Script
#  Dionysus vers. 1.0 - Macbook Pro 2018 Touchbar Edition
# ──────────────────────────────────────────────────────────────────────────

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/dotfiles" && pwd)"
CONFIG_DIR="$HOME/.config"
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

# Banner
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

🍸 Balder Dotfiles Deployment
EOF
echo -e "${NC}"

# Functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Backup existing config
backup_config() {
    local config_name=$1
    local target_path="$CONFIG_DIR/$config_name"

    if [ -e "$target_path" ]; then
        log_warning "Existing config found: $config_name"
        mkdir -p "$BACKUP_DIR"
        cp -r "$target_path" "$BACKUP_DIR/"
        log_success "Backed up to: $BACKUP_DIR/$config_name"
        return 0
    fi
    return 1
}

# Deploy a config directory
deploy_config() {
    local config_name=$1
    local source_path="$DOTFILES_DIR/$config_name"
    local target_path="$CONFIG_DIR/$config_name"

    log_info "Deploying $config_name..."

    # Check if source exists
    if [ ! -d "$source_path" ]; then
        log_error "Source not found: $source_path"
        return 1
    fi

    # Backup if exists
    backup_config "$config_name"

    # Create config directory if it doesn't exist
    mkdir -p "$CONFIG_DIR"

    # Remove existing symlink or directory
    if [ -L "$target_path" ]; then
        log_info "Removing existing symlink: $target_path"
        rm "$target_path"
    elif [ -d "$target_path" ]; then
        log_info "Removing existing directory: $target_path"
        rm -rf "$target_path"
    fi

    # Create symlink
    ln -s "$source_path" "$target_path"
    log_success "Deployed $config_name → $target_path"

    return 0
}

# Check dependencies
check_dependencies() {
    log_info "Checking dependencies..."

    local deps=("hyprland" "hyprpaper")
    local missing_deps=()

    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing_deps+=("$dep")
        fi
    done

    if [ ${#missing_deps[@]} -gt 0 ]; then
        log_warning "Missing dependencies: ${missing_deps[*]}"
        log_info "Install with: sudo pacman -S ${missing_deps[*]}"
        read -p "Continue anyway? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_error "Deployment cancelled"
            exit 1
        fi
    else
        log_success "All dependencies found"
    fi
}

# Main deployment
main() {
    echo -e "${CYAN}Starting deployment...${NC}\n"

    # Check dependencies
    check_dependencies

    echo ""
    log_info "Deployment configuration:"
    echo "  Dotfiles dir: $DOTFILES_DIR"
    echo "  Config dir:   $CONFIG_DIR"
    echo "  Backup dir:   $BACKUP_DIR"
    echo ""

    read -p "Proceed with deployment? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_error "Deployment cancelled"
        exit 1
    fi

    echo ""

    # Deploy Hyprland configuration
    deploy_config "hypr"

    # TODO: Add more configs as needed
    # deploy_config "waybar"
    # deploy_config "alacritty"
    # deploy_config "rofi"
    # deploy_config "eww"
    # deploy_config "cava"
    # deploy_config "neofetch"

    echo ""
    log_success "Deployment complete!"

    if [ -d "$BACKUP_DIR" ]; then
        log_info "Backups saved to: $BACKUP_DIR"
    fi

    echo ""
    echo -e "${CYAN}Next steps:${NC}"
    echo "  1. Review the deployed config at: $CONFIG_DIR/hypr"
    echo "  2. Customize for your Macbook Pro (keyboard layouts, monitor settings, etc.)"
    echo "  3. Reload Hyprland: hyprctl reload"
    echo ""
    echo -e "${GREEN}🍸 Welcome to Dionysus!${NC}"
}

# Run main function
main
