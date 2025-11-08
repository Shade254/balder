# greetd Configuration

Minimal TUI login manager using **tuigreet** with Hyprland integration.

## What is greetd?

greetd is a minimal and flexible login manager daemon. It's Wayland-native and officially recommended by Hyprland.

## What is tuigreet?

tuigreet is a TUI (terminal user interface) greeter for greetd - a clean, minimal login screen that runs in the terminal.

## Our Configuration

- **Theme**: Blue/cyan colors matching Hyprland aesthetic
- **Features**:
  - Remembers last username
  - Remembers last session
  - Shows current time
  - Clean minimal interface

### Color Scheme

The tuigreet theme matches your Hyprland colors:
- **Border/Prompt**: Cyan (`#56b6c2`, `#9cdef2`)
- **Text**: White
- **Actions/Buttons**: Blue (`#61afef`)
- **Container**: Black
- **Time**: Cyan

## Files

- `config.toml` - Main greetd configuration

## Installation

The `install-greetd.sh` script will:
1. Install greetd and greetd-tuigreet packages
2. Copy this config to `/etc/greetd/config.toml`
3. Disable SDDM service
4. Enable greetd service
5. Configure greeter user permissions

## Manual Installation

```bash
# Install packages
sudo pacman -S greetd greetd-tuigreet

# Copy config
sudo cp config.toml /etc/greetd/config.toml

# Ensure greeter user has video access
sudo usermod -aG video greeter

# Disable SDDM and enable greetd
sudo systemctl disable sddm.service
sudo systemctl enable greetd.service

# Reboot to see new login screen
sudo reboot
```

## Customization

To change the theme colors, edit the `--theme` argument in `config.toml`:

```toml
command = "tuigreet --theme 'border=cyan;text=white;...'"
```

Available theme components:
- `border` - Border color around elements
- `text` - Main text color
- `prompt` - Login prompt color
- `time` - Date/time display color
- `action` - Action/hint text color
- `button` - Button highlights
- `container` - Container background
- `input` - Input field text

Available colors: black, red, green, yellow, blue, magenta, cyan, white

## Reverting to SDDM

If you need to go back:

```bash
sudo systemctl disable greetd.service
sudo systemctl enable sddm.service
sudo reboot
```

## Troubleshooting

**Login screen not appearing:**
- Check service status: `systemctl status greetd.service`
- Check logs: `journalctl -u greetd.service -b`

**Can't log in:**
- Verify your username and password are correct
- Check greeter user exists: `id greeter`
- Check greeter is in video group: `groups greeter`

**Hyprland doesn't launch:**
- Verify Hyprland is installed: `which Hyprland`
- Check Hyprland config is valid
- Try launching manually from TTY: `Hyprland`
