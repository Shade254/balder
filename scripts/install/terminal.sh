#!/bin/bash
# ──────────────────────────────────────────────────────────────────────────
#  Terminal and shell tools installer
#  Installs Alacritty, ZSH, and essential command-line utilities
# ──────────────────────────────────────────────────────────────────────────

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils/logging.sh"

install_terminal() {
    log_section "Installing Terminal & Shell Dependencies"

    local terminal_packages=(
        "alacritty"
        "zsh"
        "zsh-completions"
        "zsh-autosuggestions"
        "zsh-syntax-highlighting"
        "neofetch"
        "fastfetch"        # Modern neofetch alternative
        "bat"              # Better cat
        "eza"              # Better ls
        "ripgrep"          # Better grep
        "fd"               # Better find
    )

    local missing_packages=()

    for pkg in "${terminal_packages[@]}"; do
        if ! package_installed "$pkg"; then
            missing_packages+=("$pkg")
        else
            log_info "$pkg already installed"
        fi
    done

    if [ ${#missing_packages[@]} -eq 0 ]; then
        log_success "All terminal packages already installed!"
        return 0
    fi

    log_info "Installing: ${missing_packages[*]}"

    if sudo pacman -S --needed --noconfirm "${missing_packages[@]}"; then
        log_success "Terminal packages installed successfully!"
    else
        log_error "Failed to install some packages"
        return 1
    fi
}

# Run if executed directly
if [ "${BASH_SOURCE[0]}" -ef "$0" ]; then
    install_terminal
fi
