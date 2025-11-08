#!/bin/bash
# ──────────────────────────────────────────────────────────────────────────
#  Core Hyprland dependencies installer
#  Installs essential packages for a minimal Hyprland setup
# ──────────────────────────────────────────────────────────────────────────

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils/logging.sh"

install_core() {
    log_section "Installing Core Hyprland Dependencies"

    local core_packages=(
        "hyprland"
        "hyprpaper"
        "hyprlock"
        "xdg-desktop-portal-hyprland"
        "qt5-wayland"
        "qt6-wayland"
        "polkit-kde-agent"
    )

    local missing_packages=()

    for pkg in "${core_packages[@]}"; do
        if ! package_installed "$pkg"; then
            missing_packages+=("$pkg")
        else
            log_info "$pkg already installed"
        fi
    done

    if [ ${#missing_packages[@]} -eq 0 ]; then
        log_success "All core packages already installed!"
        return 0
    fi

    log_info "Installing: ${missing_packages[*]}"

    if sudo pacman -S --needed --noconfirm "${missing_packages[@]}"; then
        log_success "Core packages installed successfully!"
    else
        log_error "Failed to install some packages"
        return 1
    fi
}

# Run if executed directly
if [ "${BASH_SOURCE[0]}" -ef "$0" ]; then
    install_core
fi
