#!/bin/bash
# ──────────────────────────────────────────────────────────────────────────
#  Waybar and status bar dependencies installer
#  Installs Waybar with all required tools and utilities
# ──────────────────────────────────────────────────────────────────────────

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils/logging.sh"

install_waybar() {
    log_section "Installing Waybar Dependencies"

    local waybar_packages=(
        "waybar"
        "playerctl"        # Media controls
        "brightnessctl"    # Brightness control
        "pipewire"
        "pipewire-pulse"   # Audio control
        "wireplumber"
        "bluez"            # Bluetooth
        "bluez-utils"
        "networkmanager"   # Network
        "jq"               # JSON parsing for scripts
    )

    local missing_packages=()

    for pkg in "${waybar_packages[@]}"; do
        if ! package_installed "$pkg"; then
            missing_packages+=("$pkg")
        else
            log_info "$pkg already installed"
        fi
    done

    if [ ${#missing_packages[@]} -eq 0 ]; then
        log_success "All Waybar packages already installed!"
        return 0
    fi

    log_info "Installing: ${missing_packages[*]}"

    if sudo pacman -S --needed --noconfirm "${missing_packages[@]}"; then
        log_success "Waybar packages installed successfully!"
    else
        log_error "Failed to install some packages"
        return 1
    fi

    # Enable bluetooth service
    if ! systemctl is-enabled bluetooth.service &> /dev/null; then
        log_info "Enabling bluetooth service..."
        sudo systemctl enable bluetooth.service
        sudo systemctl start bluetooth.service
        log_success "Bluetooth service enabled"
    fi
}

# Run if executed directly
if [ "${BASH_SOURCE[0]}" -ef "$0" ]; then
    install_waybar
fi
