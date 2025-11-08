# SDDM Configuration

Custom SDDM login screen configuration using the **Maya theme** with colors matching the Hyprland aesthetic.

## Files

- `sddm.conf` - Main SDDM configuration (theme selection, display server, user settings)
- `theme.conf` - Maya theme color customization (matching Hyprland blue/cyan palette)

## Color Scheme

The Maya theme is configured to match the Hyprland aesthetic:

- **Primary**: Dark backgrounds (`#282c34`, `#2e3440`, `#3b4252`)
- **Accent**: Blue/cyan tones (`#61afef`, `#56b6c2`, `#9cdef2`)
- **Status Colors**:
  - Success: Cyan (`#56b6c2`)
  - Failure: Red (`#e06c75`)
  - Warning: Yellow (`#e5c07b`)
- **Power Buttons**:
  - Reboot: Orange (`#fab387`)
  - Shutdown: Pink (`#f38ba8`)

## Installation

The deployment script (`deploy.sh`) will automatically:

1. Copy `sddm.conf` to `/etc/sddm.conf.d/sddm.conf`
2. Copy `theme.conf` to `/usr/share/sddm/themes/maya/theme.conf`
3. Set proper permissions

## Manual Installation

If you need to install manually:

```bash
# Copy SDDM main config
sudo cp dotfiles/sddm/sddm.conf /etc/sddm.conf.d/sddm.conf

# Copy Maya theme config
sudo cp dotfiles/sddm/theme.conf /usr/share/sddm/themes/maya/theme.conf

# Restart SDDM to apply changes
sudo systemctl restart sddm
```

## Testing

Preview the theme without restarting SDDM:

```bash
sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/maya/
```

## Customization

To modify colors, edit `dotfiles/sddm/theme.conf` and re-run the deployment script.

All color values use hex format (e.g., `#61afef`).
