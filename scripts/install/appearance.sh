#!/bin/bash
# ──────────────────────────────────────────────────────────────────────────
#  Appearance and theming installer
#  Installs Rofi, fonts, themes, and visual customization tools
# ──────────────────────────────────────────────────────────────────────────

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils/logging.sh"

install_appearance() {
    log_section "Installing Appearance & Theming Dependencies"

    local appearance_packages=(
        "rofi-wayland"
        "dunst"                    # Notifications
        "grim"                     # Screenshots
        "slurp"                    # Screen area selection
        "swappy"                   # Screenshot annotation
        "wl-clipboard"             # Clipboard utilities
        "ttf-jetbrains-mono-nerd"  # Nerd fonts
        "ttf-fira-code"
        "noto-fonts"
        "noto-fonts-emoji"
        "papirus-icon-theme"
        "qt5ct"                    # Qt5 theming
        "qt6ct"                    # Qt6 theming
        "kvantum"                  # Qt theme engine
    )

    local missing_packages=()

    for pkg in "${appearance_packages[@]}"; do
        if ! package_installed "$pkg"; then
            missing_packages+=("$pkg")
        else
            log_info "$pkg already installed"
        fi
    done

    if [ ${#missing_packages[@]} -eq 0 ]; then
        log_success "All appearance packages already installed!"
        return 0
    fi

    log_info "Installing: ${missing_packages[*]}"

    if sudo pacman -S --needed --noconfirm "${missing_packages[@]}"; then
        log_success "Appearance packages installed successfully!"
    else
        log_error "Failed to install some packages"
        return 1
    fi
}

# Run if executed directly
if [ "${BASH_SOURCE[0]}" -ef "$0" ]; then
    install_appearance
fi
