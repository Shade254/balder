#!/bin/bash
# ──────────────────────────────────────────────────────────────────────────
#  Shared backup utilities for Balder dotfiles scripts
#  Handles config backups before deployment
# ──────────────────────────────────────────────────────────────────────────

# Source logging utilities
# Get the utils directory, not the balder root
UTILS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$UTILS_DIR/logging.sh"

# Backup directory
BACKUP_DIR="${BACKUP_DIR:-$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)}"

# Backup existing config
backup_config() {
    local config_name=$1
    local target_path="${2:-$HOME/.config/$config_name}"

    if [ -e "$target_path" ]; then
        log_warning "Existing config found: $config_name"
        mkdir -p "$BACKUP_DIR"
        cp -r "$target_path" "$BACKUP_DIR/"
        log_success "Backed up to: $BACKUP_DIR/$(basename "$target_path")"
        return 0
    fi
    return 1
}

# Backup a single file
backup_file() {
    local file_path=$1

    if [ -e "$file_path" ]; then
        local file_name=$(basename "$file_path")
        log_warning "Existing file found: $file_name"
        mkdir -p "$BACKUP_DIR"
        cp "$file_path" "$BACKUP_DIR/"
        log_success "Backed up to: $BACKUP_DIR/$file_name"
        return 0
    fi
    return 1
}
