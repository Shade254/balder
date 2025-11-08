# Complete Setup Guide

**Comprehensive technical reference for Balder dotfiles**

This document covers everything from fresh installation to advanced customization. For quick setup, see [QUICKSTART.md](QUICKSTART.md).

---

## Table of Contents

1. [System Requirements](#system-requirements)
2. [Installation](#installation)
3. [Configuration](#configuration)
4. [Hardware Integration](#hardware-integration)
5. [Customization](#customization)
6. [Troubleshooting](#troubleshooting)
7. [Advanced Topics](#advanced-topics)

---

## System Requirements

### Minimum Requirements

- **OS:** Arch Linux (or Arch-based distro)
- **Display Server:** Wayland
- **GPU:** Any with OpenGL 3.0+ support
- **RAM:** 2GB minimum (4GB recommended)
- **Disk:** 10GB for full installation with dependencies

### Recommended Hardware

- **Laptop:** MacBook Pro 2018 T2 (native support)
- **CPU:** Intel with P-State driver (for power management)
- **Display:** HiDPI aware (scales tested: 1.0, 1.25, 1.5)

### Required Software

**Base System:**
- Arch Linux installation with working network
- `base-devel` package group
- `git` for cloning repository

**Core Dependencies:**
- Hyprland (window manager)
- Waybar (status bar)
- hyprpaper (wallpaper daemon)
- hyprlock (screen locker)

**Additional Components:**
- Alacritty (terminal emulator)
- Rofi (application launcher)
- ZSH (shell)
- Font with Nerd Font support

All dependencies can be installed via the included `install.sh` script.

---

## Installation

### Option 1: Quick Install (Recommended)

```bash
# Clone repository
git clone https://github.com/YOUR_USERNAME/balder.git ~/balder
cd ~/balder

# Install all dependencies
./install.sh --all

# Deploy dotfiles
./deploy.sh

# Reboot to apply changes
sudo reboot
```

### Option 2: Modular Install

```bash
# Clone repository
git clone https://github.com/YOUR_USERNAME/balder.git ~/balder
cd ~/balder

# Choose components interactively
./install.sh

# Or select specific modules
./install.sh --core --waybar --terminal

# Deploy selected configs
./deploy.sh
```

### Option 3: Manual Install

For experienced users who want full control:

```bash
# 1. Install dependencies manually
sudo pacman -S hyprland hyprpaper waybar hyprlock \
               alacritty rofi zsh \
               ttf-jetbrains-mono-nerd \
               playerctl brightnessctl pipewire-pulse

# 2. Clone repository
git clone https://github.com/YOUR_USERNAME/balder.git ~/balder

# 3. Create symlinks
ln -s ~/balder/dotfiles/hypr ~/.config/hypr
ln -s ~/balder/dotfiles/waybar ~/.config/waybar
ln -s ~/balder/dotfiles/alacritty ~/.config/alacritty
ln -s ~/balder/dotfiles/rofi ~/.config/rofi
ln -s ~/balder/dotfiles/zsh/.zshrc ~/.zshrc

# 4. Install udev rules (for hardware control)
sudo cp ~/balder/dotfiles/system/*.rules /etc/udev/rules.d/
sudo udevadm control --reload
sudo udevadm trigger

# 5. Reload Hyprland
hyprctl reload
```

---

## Configuration

### First Boot Checklist

After installation and reboot:

**1. Verify Hyprland is running**
```bash
echo $XDG_SESSION_TYPE  # Should output: wayland
ps aux | grep hyprland
```

**2. Check Waybar**
- Should appear at top of screen
- Modules should display correctly
- Clock, workspace indicators, system tray visible

**3. Test wallpaper**
```bash
pgrep hyprpaper  # Should return a PID
```

**4. Test screen lock**
```bash
hyprlock  # Or press Super+L
# Type password to unlock
```

**5. Verify hardware controls**
- F5: Cycle power profiles
- F3/F4: Adjust keyboard brightness (if applicable)
- Volume keys: Adjust audio
- Brightness keys: Adjust screen brightness

### Monitor Configuration

**Single monitor:**
```conf
# dotfiles/hypr/hyprland.conf (line 8)
monitor = eDP-1, preferred, auto, 1.25
```

**Multiple monitors:**
```conf
# Primary monitor (laptop screen)
monitor = eDP-1, 2560x1600@60, 0x0, 1.25

# External monitor (right of laptop)
monitor = DP-1, 1920x1080@60, 2560x0, 1.0

# External monitor (above laptop)
monitor = HDMI-A-1, 3840x2160@30, 0x-2160, 1.5
```

**Find your monitor names:**
```bash
hyprctl monitors
```

### Keyboard Layout

```conf
# dotfiles/hypr/hyprland.conf (line 121)
kb_layout = gb,se  # UK and Swedish layouts
kb_options = grp:alt_shift_toggle  # Switch with Alt+Shift
```

**Common layouts:**
- `us` - US English
- `gb` - UK English
- `de` - German
- `fr` - French
- `se` - Swedish
- `no` - Norwegian

### Touchpad Settings

```conf
# dotfiles/hypr/hyprland.conf (lines 130-132)
input {
    touchpad {
        natural_scroll = yes  # Mac-style scrolling
        tap-to-click = yes
        disable_while_typing = yes
    }
}
```

---

## Hardware Integration

### Power Management (Intel CPUs)

**How it works:**
- Uses Intel Energy Performance Preference (EPP)
- Three profiles: power, balance_performance, performance
- Cycles with F5 key (XF86Launch4)
- Visual feedback in Waybar

**Profile Details:**
| Profile | EPP Value | Name | Use Case |
|---------|-----------|------|----------|
| Power Save | `power` | REACTOR SLEEP | Max battery life |
| Balanced | `balance_performance` | STABILIZATION | Daily use |
| Performance | `performance` | RAZGON | Max performance |

**Configuration Files:**
- Script: `dotfiles/hypr/scripts/t2-power/cycle-power-mode.sh`
- Waybar module: `dotfiles/waybar/scripts/power-profile.sh`
- udev rule: `dotfiles/system/99-cpu-epp.rules`

**Manual control:**
```bash
# Set performance mode
echo "performance" | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference

# Check current mode
cat /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference
```

### Keyboard Backlight

**Supported platforms:**
- MacBook Pro (T2 and earlier): `/sys/class/leds/apple::kbd_backlight/`
- ThinkPad: `/sys/class/leds/tpacpi::kbd_backlight/`
- ASUS: `/sys/class/leds/asus::kbd_backlight/`
- Dell: `/sys/class/leds/dell::kbd_backlight/`

**Scripts:**
- Brightness control: `dotfiles/hypr/scripts/t2-kbd/kbd-brightness.sh`
- Breathing effect: `dotfiles/hypr/scripts/t2-kbd/kbd-breathing.sh`

**Keybindings:**
- F3: Decrease brightness (XF86KbdBrightnessDown)
- F4: Increase brightness / Toggle breathing (XF86KbdBrightnessUp / XF86Launch3)

**Adapt for your hardware:**
```bash
# 1. Find your keyboard backlight path
ls /sys/class/leds/

# 2. Edit scripts to use your path
# Replace "apple::kbd_backlight" with your device

# 3. Update udev rule
# dotfiles/system/99-kbd-backlight.rules
```

### Audio Control

**Volume:**
- Increase: XF86AudioRaiseVolume
- Decrease: XF86AudioLowerVolume
- Mute: XF86AudioMute

**Media controls:**
- Play/Pause: XF86AudioPlay
- Next: XF86AudioNext
- Previous: XF86AudioPrev

**Waybar modules:**
- Volume display with mute indicator
- Microphone status with mute toggle
- Click volume to mute/unmute

**Backend:** PipeWire via `wpctl` (wireplumber)

### Screen Brightness

**Controls:**
- Increase: XF86MonBrightnessUp
- Decrease: XF86MonBrightnessDown

**Tool:** `brightnessctl`

**Manual adjustment:**
```bash
# Increase by 10%
brightnessctl set +10%

# Decrease by 10%
brightnessctl set 10%-

# Set to 50%
brightnessctl set 50%
```

### Bluetooth

**Waybar toggle:**
- Click Bluetooth module to toggle on/off
- Shows connection status and device count

**Manual control:**
```bash
# Enable Bluetooth
bluetoothctl power on

# Pair device
bluetoothctl
> scan on
> pair XX:XX:XX:XX:XX:XX
> connect XX:XX:XX:XX:XX:XX
> trust XX:XX:XX:XX:XX:XX
```

**Service management:**
```bash
# Enable on boot
sudo systemctl enable bluetooth.service

# Start now
sudo systemctl start bluetooth.service
```

---

## Customization

### Theme Colors

**Color Palette:**
```conf
# Nord-inspired with neon accents
Blue:       #61afef  # Active borders, prompts
Cyan:       #56b6c2  # Accents, success states
Light Cyan: #9cdef2  # Highlights
Red:        #e06c75  # Errors, failures
Orange:     #fab387  # Warnings (CAPS LOCK)
Yellow:     #e5c07b  # Attention
Green:      #98c379  # Success
Purple:     #c678dd  # Special elements
Background: #282c34  # Dark background
Foreground: #abb2bf  # Text
```

**Where to change:**
- **Hyprland:** `dotfiles/hypr/hyprland.conf` (border colors, gaps)
- **Waybar:** `dotfiles/waybar/style.css` (bar appearance)
- **hyprlock:** `dotfiles/hypr/hyprlock.conf` (lock screen)
- **Alacritty:** `dotfiles/alacritty/alacritty.toml` (terminal colors)
- **Rofi:** `dotfiles/rofi/config.rasi` (launcher theme)

### Wallpapers

**Add wallpapers:**
```bash
# Copy images to wallpaper directory
cp ~/Pictures/my_wallpaper.png ~/balder/dotfiles/hypr/wallpapers/

# Edit hyprpaper config
nano ~/balder/dotfiles/hypr/hyprpaper.conf
```

**hyprpaper.conf format:**
```conf
preload = ~/.config/hypr/wallpapers/my_wallpaper.png
wallpaper = eDP-1, ~/.config/hypr/wallpapers/my_wallpaper.png
```

**Reload wallpaper:**
```bash
killall hyprpaper
hyprpaper &
```

### Waybar Modules

**Available modules:**
- `hyprland/workspaces` - Workspace indicators
- `clock` - Date and time
- `battery` - Battery status (laptops)
- `pulseaudio` - Volume control
- `network` - Network status
- `bluetooth` - Bluetooth toggle
- `cpu` / `memory` / `disk` - System resources
- `custom/power-profile` - Power profile indicator
- `tray` - System tray

**Enable/disable modules:**
Edit `dotfiles/waybar/config` (line 6-30)

```json
"modules-right": [
    "pulseaudio",
    "network",
    "bluetooth",
    "battery",
    "custom/power-profile",
    "clock",
    "tray"
],
```

**Create custom module:**
```json
"custom/my-module": {
    "exec": "~/.config/waybar/scripts/my-script.sh",
    "interval": 5,
    "format": "{}",
    "tooltip": false
}
```

### Keybindings

**Main categories:**
- **Super + ...** : Window management
- **Super + Shift + ...** : Advanced window actions
- **F-keys / XF86...** : Hardware controls
- **Super + Alt + ...** : Workspace switching

**Common bindings:**
| Keys | Action |
|------|--------|
| Super + Q | Close window |
| Super + Return | Terminal |
| Super + E | File manager |
| Super + Space | Rofi launcher |
| Super + L | Lock screen |
| Super + V | Toggle floating |
| Super + F | Toggle fullscreen |
| Super + 1-9 | Switch workspace |
| Super + Shift + 1-9 | Move to workspace |

**Add custom binding:**
```conf
# dotfiles/hypr/hyprland.conf
bind = SUPER, B, exec, firefox  # Super+B opens Firefox
```

### Auto-start Applications

**Edit:** `dotfiles/hypr/hyprland.conf` (lines 230-250)

```conf
# Start on Hyprland launch
exec-once = waybar
exec-once = hyprpaper
exec-once = dunst  # Notifications
exec-once = /usr/lib/polkit-kde-authentication-agent-1

# Your custom apps
exec-once = discord --start-minimized
exec-once = spotify
```

### Window Rules

**Automatic window placement:**
```conf
# Float specific windows
windowrule = float, ^(rofi)$
windowrule = float, ^(pavucontrol)$

# Workspace assignments
windowrule = workspace 2, ^(firefox)$
windowrule = workspace 3, ^(Code)$

# Opacity
windowrule = opacity 0.9, ^(Alacritty)$
```

---

## Troubleshooting

### Services Not Starting

**Check logs:**
```bash
# Hyprland log
cat ~/.config/hypr/hypr.log

# Waybar log (if run from terminal)
killall waybar
waybar  # Run in foreground to see errors

# System journal
journalctl --user -xe
```

**Common issues:**
- Missing dependencies → Run `./install.sh --all`
- Wrong monitor name → Check `hyprctl monitors`
- GPU driver issues → Install mesa/nvidia/amd drivers

### Hardware Controls Not Working

**Verify udev rules:**
```bash
ls -la /etc/udev/rules.d/99-*.rules
```

**Reinstall rules:**
```bash
sudo cp ~/balder/dotfiles/system/*.rules /etc/udev/rules.d/
sudo udevadm control --reload
sudo udevadm trigger
```

**Test sysfs access:**
```bash
# Should NOT require sudo
echo "performance" > /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference

# If denied, udev rules not applied correctly
```

### Waybar Modules Not Updating

**Power profile stuck:**
```bash
# Kill and restart cycle script
pkill -f cycle-power-mode
~/.config/hypr/scripts/t2-power/cycle-power-mode.sh
```

**General Waybar restart:**
```bash
killall waybar
waybar &
```

### Screen Lock Issues

**hyprlock won't start:**
```bash
# Check if process exists
pgrep hyprlock

# Kill existing instance
killall hyprlock

# Test config
hyprlock --config ~/.config/hypr/hyprlock.conf
```

**Can't unlock:**
- Ensure PAM is configured correctly
- Check keyboard layout (password might be typed wrong)
- Fallback: Switch to TTY (Ctrl+Alt+F2), login, kill hyprlock

### Performance Issues

**Check compositor overhead:**
```bash
# Disable blur temporarily
hyprctl keyword decoration:blur:enabled false

# Disable shadows
hyprctl keyword decoration:drop_shadow false
```

**Reduce animations:**
```conf
# dotfiles/hypr/hyprland.conf
animations {
    enabled = no
}
```

**Monitor resource usage:**
```bash
htop  # Check CPU/RAM
nvidia-smi  # Check GPU (NVIDIA)
```

---

## Advanced Topics

### Custom Scripts Location

```
balder/
├── dotfiles/
│   ├── hypr/scripts/
│   │   ├── t2-kbd/          # Keyboard controls
│   │   ├── t2-power/        # Power management
│   │   ├── waybar_watcher.sh  # Eww/Waybar switcher
│   │   └── refresh-eww.sh
│   └── waybar/scripts/
│       ├── power-profile.sh # Power profile display
│       ├── nordvpn-*.sh     # VPN controls
│       ├── brightness.sh    # Brightness display
│       └── workspaces/      # Workspace scripts
└── scripts/
    ├── install/             # Modular installers
    ├── setup/               # Setup helpers
    └── utils/               # Shared utilities
```

### Eww Widgets Integration

**Note:** Eww widgets are included but disabled by default (replaced by Waybar).

**To enable Eww:**
1. Install Eww: `yay -S eww-wayland` (AUR)
2. Review `dotfiles/eww/` configuration
3. Enable waybar_watcher.sh to toggle between Waybar/Eww based on workspace state

### NordVPN Integration

**Install NordVPN:**
```bash
yay -S nordvpn-bin
sudo systemctl enable --now nordvpnd
sudo usermod -aG nordvpn $USER
```

**Waybar integration:**
- Toggle: Click NordVPN module
- Status: Shows connection state and location
- Scripts: `dotfiles/waybar/scripts/nordvpn-*.sh`

### Login Manager (greetd)

**Already configured if deployed.** To customize:

**greetd config:** `/etc/greetd/config.toml`
```toml
[terminal]
vt = 1

[default_session]
command = "tuigreet --time --cmd Hyprland"
user = "greeter"
```

**tuigreet theme:**
- Colors set via greetd config
- Blue/cyan theme matches Hyprland

**Alternative greeters:**
- `greetd-gtkgreet` (GTK GUI)
- `regreet` (GTK4 GUI)
- `agreety` (basic TUI)

### Backup and Restore

**Backup your customizations:**
```bash
# Create archive
cd ~/balder
tar -czf ~/balder-backup-$(date +%Y%m%d).tar.gz \
    dotfiles/ docs/ scripts/ install.sh deploy.sh

# Sync to remote
rsync -avz ~/balder/ user@server:~/balder-backup/
```

**Restore:**
```bash
# Extract backup
tar -xzf ~/balder-backup-20250108.tar.gz -C ~/

# Redeploy
cd ~/balder
./deploy.sh
```

### Updating from Repository

```bash
cd ~/balder

# Stash local changes
git stash

# Pull updates
git pull origin main

# Reapply local changes
git stash pop

# Redeploy if configs changed
./deploy.sh
```

---

## See Also

- [QUICKSTART.md](QUICKSTART.md) - Fast setup for forkers
- [MIGRATION_HISTORY.md](MIGRATION_HISTORY.md) - Hardware migration details
- [Hyprland Wiki](https://wiki.hyprland.org)
- [Waybar Documentation](https://github.com/Alexays/Waybar/wiki)

---

**Document Version:** 1.0
**Last Updated:** 2025-01-08
**Maintained by:** Balder Project
