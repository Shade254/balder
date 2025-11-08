# Balder Dotfiles Deployment Guide

🍸 **Dionysus vers. 1.0** - Macbook Pro 2018 Touchbar Edition

## Quick Start

```bash
# Clone the repo (you already did this!)
git clone <your-repo-url> ~/balder
cd ~/balder

# Run deployment
./deploy.sh
```

## What the Script Does

1. **Checks dependencies** - Verifies Hyprland, hyprpaper, and waybar are installed
2. **Creates backups** - Backs up existing configs to `~/.dotfiles-backup-TIMESTAMP/`
3. **Deploys configs** - Creates symlinks from `~/.config/` to your dotfiles
4. **Reloads services** - Automatically restarts hyprpaper, waybar, and reloads Hyprland
5. **Verifies everything** - Ensures all services are running after deployment

## Current Deployment

- ✅ **Hyprland** (`~/.config/hypr/`)
- ✅ **Hyprpaper** (wallpaper daemon, auto-starts with Hyprland)
- ✅ **Waybar** (status bar with custom modules)

## Coming Soon (Uncomment in deploy.sh)

- ⏳ Alacritty
- ⏳ Rofi
- ⏳ Eww
- ⏳ Cava
- ⏳ Neofetch

## Customization for Your Macbook Pro

After deployment, you'll want to customize:

### 1. Monitor Configuration
Edit `~/.config/hypr/hyprland.conf`:
```conf
# Line 8: Change monitor name and scale for your Macbook
monitor = eDP-1, preferred, auto, 1.25
```

### 2. Keyboard Layouts
```conf
# Line 121: Set your keyboard layouts
kb_layout = gb, se,  # Change to your preferred layouts
```

### 3. MacBook T2 Hardware Setup

**IMPORTANT:** After running `./deploy.sh`, install the udev rules for passwordless hardware control:

```bash
sudo cp dotfiles/system/*.rules /etc/udev/rules.d/
sudo udevadm control --reload
sudo udevadm trigger
```

This enables:
- Intel EPP power management (F5 to cycle profiles)
- Keyboard backlight control (F3/F4 for brightness, F4 for breathing effect)

### 4. Touchpad Settings
Line 130-132 already has natural scrolling enabled, which is great for Mac users!

### 5. Firefox Profile Path
Line 20: Update to your Firefox profile path

## Extending the Deployment

To add more configs, edit `deploy.sh` and uncomment:

```bash
# deploy_config "waybar"
# deploy_config "alacritty"
```

Or add your own:
```bash
deploy_config "your-config-name"
```

## Rollback

If something goes wrong, your backups are in:
```
~/.dotfiles-backup-TIMESTAMP/
```

Just copy them back:
```bash
cp -r ~/.dotfiles-backup-TIMESTAMP/hypr ~/.config/
```

## Manual Installation (Alternative)

If you prefer manual setup:
```bash
# Backup existing config
mv ~/.config/hypr ~/.config/hypr.backup

# Create symlink
ln -s ~/balder/dotfiles/hypr ~/.config/hypr

# Reload Hyprland
hyprctl reload
```

## Dependencies

Current minimal dependencies:
- `hyprland` - Window manager
- `hyprpaper` - Wallpaper daemon
- `waybar` - Status bar

Full setup dependencies (for complete rice):
- `waybar` - Status bar
- `rofi` - Launcher
- `alacritty` - Terminal
- `eww` - Widgets
- `cava` - Visualizer
- `neofetch` - System info
- `firefox` - Browser
- `thunar` - File manager
- `grim` + `slurp` - Screenshots
- `playerctl` - Media controls
- `brightnessctl` - Brightness control
- `wpctl` (pipewire) - Audio control

Install all at once:
```bash
sudo pacman -S hyprland hyprpaper waybar rofi alacritty eww cava neofetch firefox thunar grim slurp playerctl brightnessctl pipewire-pulse
```

## Troubleshooting

**Script won't run:**
```bash
chmod +x deploy.sh
```

**Symlinks not working:**
Make sure you're running from the repo directory, not from a different location.

**Hyprland won't start:**
Check logs: `~/.config/hypr/hypr.log`

**Wallpaper not showing:**
The deployment script automatically restarts hyprpaper. If it still doesn't show:
```bash
killall hyprpaper
hyprpaper &
```

**Waybar not appearing:**
The deployment script automatically restarts waybar. If it's not visible:
```bash
killall waybar
waybar &
```

**Services didn't reload:**
The script automatically reloads all services. For manual reload:
```bash
hyprctl reload          # Reload Hyprland config
killall hyprpaper && hyprpaper &  # Restart wallpaper
killall waybar && waybar &        # Restart status bar
```

## Next Steps

1. ✅ Deploy basic Hyprland config
2. 🔧 Customize for Macbook Pro hardware
3. 🎨 Tweak theme colors and animations
4. 📦 Add more configs as needed
5. 🚀 Enjoy your rice!

---

## MacBook Pro 2018 T2 Edition

**Note:** This configuration is now optimized for MacBook Pro T2 hardware. If you're running on different hardware (ASUS ROG, etc.), power management and keyboard controls may need adjustment.

### T2-Specific Features
- **Intel EPP** power management with nuclear theme (REACTOR SLEEP / STABILIZATION / RAZGON)
- **Keyboard backlight** control with breathing effects
- **Event-driven** Waybar updates (zero polling)
- **Hardware Controls**: F3/F4 for keyboard backlight, F5 for power profiles

🍸 **Добро пожаловать, командир!**
