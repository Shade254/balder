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

# Reload services after deployment
reload_services() {
    log_info "Reloading services..."
    echo ""

    # Reload Hyprland configuration
    if command -v hyprctl &> /dev/null; then
        log_info "Reloading Hyprland configuration..."
        hyprctl reload &> /dev/null && log_success "Hyprland reloaded" || log_warning "Failed to reload Hyprland"
    fi

    # Restart hyprpaper (wallpaper daemon)
    if command -v hyprpaper &> /dev/null; then
        log_info "Restarting hyprpaper..."
        killall hyprpaper 2>/dev/null
        hyprpaper &> /dev/null &
        sleep 1
        if pgrep -x hyprpaper > /dev/null; then
            log_success "hyprpaper restarted"
        else
            log_warning "hyprpaper may not be running"
        fi
    fi

    # Restart waybar (status bar)
    if command -v waybar &> /dev/null; then
        log_info "Restarting waybar..."
        killall waybar 2>/dev/null
        waybar &> /dev/null &
        sleep 1
        if pgrep -x waybar > /dev/null; then
            log_success "waybar restarted"
        else
            log_warning "waybar may not be running"
        fi
    fi

    # Setup rofi image cache (required for theme)
    if [ -f "$CONFIG_DIR/rofi/image.png" ]; then
        log_info "Setting up rofi image cache..."
        cp "$CONFIG_DIR/rofi/image.png" /dev/shm/rofi_image.png 2>/dev/null && \
            log_success "Rofi image cached" || \
            log_warning "Failed to cache rofi image"
    fi

    echo ""
    log_success "All services reloaded!"
}

# Check dependencies
check_dependencies() {
    log_info "Checking dependencies..."

    local deps=("hyprland" "hyprpaper" "waybar" "rofi")
    local missing_deps=()

    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing_deps+=("$dep")
        fi
    done

    if [ ${#missing_deps[@]} -gt 0 ]; then
        log_warning "Missing dependencies: ${missing_deps[*]}"
        log_info "Install with: sudo pacman -S ${missing_deps[*]}"
        log_warning "Continuing anyway..."
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
    log_info "Proceeding with deployment..."
    echo ""

    # Deploy Hyprland configuration
    deploy_config "hypr"

    # Deploy Waybar (status bar)
    deploy_config "waybar"

    # Make waybar scripts executable
    if [ -d "$CONFIG_DIR/waybar/scripts" ]; then
        log_info "Setting waybar scripts as executable..."
        chmod +x "$CONFIG_DIR/waybar/scripts"/*.sh 2>/dev/null && \
            log_success "Waybar scripts are now executable" || \
            log_warning "Some scripts may not be executable"
    fi

    # Deploy Rofi (application launcher)
    deploy_config "rofi"

    # TODO: Add more configs as needed
    # deploy_config "alacritty"
    # deploy_config "eww"
    # deploy_config "cava"
    # deploy_config "neofetch"

    echo ""
    log_success "Deployment complete!"

    if [ -d "$BACKUP_DIR" ]; then
        log_info "Backups saved to: $BACKUP_DIR"
    fi

    echo ""

    # Reload all services to apply changes
    reload_services

    echo ""
    echo -e "${CYAN}Next steps:${NC}"
    echo "  1. Review the deployed config at: $CONFIG_DIR/hypr"
    echo "  2. Customize for your Macbook Pro (keyboard layouts, monitor settings, etc.)"
    echo "  3. Your wallpaper and statusbar should now be visible!"
    echo ""
    echo -e "${GREEN}🍸 Welcome to Dionysus!${NC}"
}

# Run main function
main
