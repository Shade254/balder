#!/bin/bash
# ──────────────────────────────────────────────────────────────────────────
#  Extra widgets and tools installer
#  Installs Eww, Cava, and other optional enhancements
# ──────────────────────────────────────────────────────────────────────────

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils/logging.sh"

install_extras() {
    log_section "Installing Extra Widgets & Tools"

    local extra_packages=(
        "cava"             # Audio visualizer
        "btop"             # System monitor
        "thunar"           # File manager
        "thunar-archive-plugin"
        "file-roller"      # Archive manager
        "mpv"              # Video player
        "imv"              # Image viewer
    )

    local missing_packages=()

    for pkg in "${extra_packages[@]}"; do
        if ! package_installed "$pkg"; then
            missing_packages+=("$pkg")
        else
            log_info "$pkg already installed"
        fi
    done

    if [ ${#missing_packages[@]} -eq 0 ]; then
        log_success "All extra packages already installed!"
        return 0
    fi

    log_info "Installing: ${missing_packages[*]}"

    if sudo pacman -S --needed --noconfirm "${missing_packages[@]}"; then
        log_success "Extra packages installed successfully!"
    else
        log_error "Failed to install some packages"
        return 1
    fi

    # Check for eww (AUR package)
    if ! command_exists eww; then
        log_warning "Eww not found. To install Eww, use an AUR helper:"
        log_info "  yay -S eww-wayland"
        log_info "  paru -S eww-wayland"
    else
        log_success "Eww already installed"
    fi
}

# Run if executed directly
if [ "${BASH_SOURCE[0]}" -ef "$0" ]; then
    install_extras
fi
