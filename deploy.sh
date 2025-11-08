#!/bin/bash
# ──────────────────────────────────────────────────────────────────────────
#  °˖* ૮( • ᴗ ｡)っ🍸 Balder Dotfiles Deployment Script
#  Dionysus vers. 1.0 - MacBook Pro 2018 Touchbar Edition
# ──────────────────────────────────────────────────────────────────────────
#
#  Deploy dotfiles by creating symlinks from ~/.config to this repo.
#  This script focuses on configuration deployment only.
#  For dependency installation, run ./install.sh first.
#
# ──────────────────────────────────────────────────────────────────────────

set -e  # Exit on error

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source utilities
source "$SCRIPT_DIR/scripts/utils/logging.sh"
source "$SCRIPT_DIR/scripts/utils/backup.sh"

# Configuration
DOTFILES_DIR="$SCRIPT_DIR/dotfiles"
CONFIG_DIR="$HOME/.config"
export BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

# Show banner
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

🍸 Balder Dotfiles Deployment
EOF
    echo -e "${NC}"
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

# Check if dependencies are installed
check_dependencies() {
    log_info "Checking dependencies..."

    local deps=("hyprland" "hyprpaper" "waybar")
    local missing_deps=()

    for dep in "${deps[@]}"; do
        if ! command_exists "$dep"; then
            missing_deps+=("$dep")
        fi
    done

    if [ ${#missing_deps[@]} -gt 0 ]; then
        log_warning "Missing dependencies: ${missing_deps[*]}"
        echo ""
        log_error "Please run ./install.sh first to install dependencies!"
        echo ""
        log_info "Quick install: ./install.sh --all"
        return 1
    else
        log_success "All core dependencies found"
    fi
}

# Main deployment
main() {
    show_banner

    log_section "Starting Deployment"

    # Check dependencies
    if ! check_dependencies; then
        exit 1
    fi

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

    # Deploy Alacritty (terminal emulator)
    deploy_config "alacritty"

    # Deploy Neofetch (animated system info)
    deploy_config "neofetch"

    # Make neofetch animation script executable
    if [ -f "$CONFIG_DIR/neofetch/animated-neofetch.sh" ]; then
        log_info "Setting neofetch animation script as executable..."
        chmod +x "$CONFIG_DIR/neofetch/animated-neofetch.sh" && \
            log_success "Neofetch animation script is now executable" || \
            log_warning "Failed to make neofetch script executable"
    fi

    # Deploy ZSH configuration
    log_info "Deploying ZSH configuration..."
    if [ -f "$HOME/.zshrc" ]; then
        backup_file "$HOME/.zshrc"
        rm -f "$HOME/.zshrc"
    fi
    ln -s "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
    log_success "ZSH configuration deployed → $HOME/.zshrc"

    echo ""
    log_section "Deployment Complete!"

    if [ -d "$BACKUP_DIR" ]; then
        log_info "Backups saved to: $BACKUP_DIR"
    fi

    echo ""

    # Reload all services to apply changes
    reload_services

    echo ""
    echo -e "${CYAN}🐚  Shell Configuration:${NC}"

    # Check if ZSH is default shell
    current_shell=$(getent passwd "$USER" | cut -d: -f7)
    if [ "$current_shell" = "/bin/zsh" ]; then
        log_success "ZSH is your default shell"
    else
        log_warning "ZSH is not your default shell (currently: $current_shell)"
        echo -e "${YELLOW}To make ZSH your default shell, run:${NC}"
        echo -e "  ${GREEN}chsh -s /bin/zsh${NC}"
        echo -e "${YELLOW}(Takes effect on next login)${NC}"
    fi

    echo ""
    echo -e "${CYAN}⚙️  MacBook T2 Hardware Setup:${NC}"

    # Check if udev rules are installed
    local missing_rules=false

    if [ ! -f "/etc/udev/rules.d/99-cpu-epp.rules" ]; then
        log_warning "Intel EPP udev rule not installed!"
        missing_rules=true
    else
        log_success "Intel EPP udev rule installed"
    fi

    if [ ! -f "/etc/udev/rules.d/99-kbd-backlight.rules" ]; then
        log_warning "Keyboard backlight udev rule not installed!"
        missing_rules=true
    else
        log_success "Keyboard backlight udev rule installed"
    fi

    if [ "$missing_rules" = true ]; then
        echo ""
        log_warning "Missing udev rules detected. Installing now..."
        echo -e "${YELLOW}This requires sudo privileges to copy files to /etc/udev/rules.d/${NC}"

        # Install udev rules with sudo
        if sudo cp "$DOTFILES_DIR/system/"*.rules /etc/udev/rules.d/ 2>/dev/null; then
            log_success "Udev rules copied to /etc/udev/rules.d/"

            # Reload udev rules
            if sudo udevadm control --reload && sudo udevadm trigger; then
                log_success "Udev rules reloaded and applied"
                echo ""
                log_info "Udev rules are now active! Power profile and keyboard backlight controls enabled."
            else
                log_error "Failed to reload udev rules"
            fi
        else
            log_error "Failed to copy udev rules. Please run manually:"
            echo -e "  ${GREEN}sudo cp dotfiles/system/*.rules /etc/udev/rules.d/${NC}"
            echo -e "  ${GREEN}sudo udevadm control --reload && sudo udevadm trigger${NC}"
        fi
        echo ""
    fi

    echo ""
    echo -e "${CYAN}Next steps:${NC}"
    echo "  1. Review the deployed config at: $CONFIG_DIR/hypr"
    echo "  2. Test power profile cycling with F5 (XF86Launch4)"
    echo "  3. Test keyboard backlight with F3/F4"
    echo "  4. Test screen lock with Cmd+L (Super+L)"
    echo "  5. Your wallpaper and statusbar should now be visible!"
    echo ""
    echo -e "${GREEN}🍸 Welcome to Dionysus - MacBook T2 Edition!${NC}"
}

# Run main function
main
