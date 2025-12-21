# 📸 Screenshot Setup - Balder

## Overview

Screenshot functionality for Balder using `grim` + `slurp` on Hyprland/Wayland.

## Features

- ✅ Full screen screenshots
- ✅ Area selection screenshots
- ✅ Active window screenshots
- ✅ Automatic clipboard copy
- ✅ Desktop notifications with preview
- ✅ Auto-timestamped filenames
- ✅ Saved to `~/Pictures/Screenshots/`

## Dependencies

All dependencies are already installed:
- `grim` - Screenshot utility for Wayland
- `slurp` - Region selector for Wayland
- `wl-clipboard` - Wayland clipboard utilities
- `libnotify` - Desktop notifications
- `jq` - JSON processor (for window geometry)

## Keybindings

| Keybinding | Action |
|------------|--------|
| `Super + P` | Area screenshot (select region) - most common |
| `Super + Shift + P` | Full screen screenshot |
| `Super + Alt + P` | Active window screenshot |
| `Print` | Full screen screenshot (alternative) |

> **Note:** All screenshot bindings use "P" (Picture) with different modifiers. This avoids conflicts with workspace movement keybindings (Super+Shift+1-9).

## Script Location

- **Repository:** `dotfiles/hypr/scripts/screenshot.sh`
- **System:** `~/.config/hypr/scripts/screenshot.sh` (symlinked)

## Usage

### Via Keybindings
Just press the appropriate key combination above.

### Via Command Line

```bash
# Area selection (default)
~/.config/hypr/scripts/screenshot.sh area

# Full screen
~/.config/hypr/scripts/screenshot.sh full

# Active window
~/.config/hypr/scripts/screenshot.sh window
```

## Screenshot Storage

All screenshots are saved to:
```
~/Pictures/Screenshots/screenshot-{type}-YYYY-MM-DD-HHMMSS.png
```

Examples:
- `screenshot-full-2025-11-14-204434.png`
- `screenshot-area-2025-11-14-205612.png`
- `screenshot-window-2025-11-14-210345.png`

## How It Works

1. **Full Screen**: Captures entire display using `grim`
2. **Area Selection**: Uses `slurp` to select region, then captures with `grim`
3. **Active Window**: Queries Hyprland for active window geometry via `hyprctl`, then captures with `grim`

All screenshots are automatically copied to clipboard and show a notification with preview.

## Configuration

Edit `dotfiles/hypr/scripts/screenshot.sh` to customize:
- Screenshot directory location
- Filename format
- Notification settings

After editing, run:
```bash
./deploy.sh
```

## Troubleshooting

### Screenshots not working?
1. Check if script is executable:
   ```bash
   ls -la ~/.config/hypr/scripts/screenshot.sh
   ```

2. Test manually:
   ```bash
   ~/.config/hypr/scripts/screenshot.sh full
   ```

3. Check dependencies:
   ```bash
   pacman -Qs grim slurp wl-clipboard
   ```

### No notifications?
- Ensure `libnotify` is installed
- Check notification daemon is running (usually part of Hyprland setup)

### Can't find screenshots?
- Check: `~/Pictures/Screenshots/`
- Script creates this directory automatically on first run

## Related Documentation

- [Hyprland Configuration](hyprland.conf)
- [Deployment Guide](../README.md)

---

**Last Updated:** 2025-11-14
**Tested On:** Arch Linux + Hyprland (MacBook Pro 2018 T2)
