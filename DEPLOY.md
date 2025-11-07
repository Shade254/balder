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

1. **Checks dependencies** - Verifies Hyprland is installed
2. **Creates backups** - Backs up existing configs to `~/.dotfiles-backup-TIMESTAMP/`
3. **Deploys configs** - Creates symlinks from `~/.config/` to your dotfiles
4. **Confirms actions** - Asks before making changes

## Current Deployment

- ✅ **Hyprland** (`~/.config/hypr/`)
- ✅ **Hyprpaper** (wallpaper daemon, auto-starts with Hyprland)

## Coming Soon (Uncomment in deploy.sh)

- ⏳ Waybar
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

### 3. ASUS-Specific Scripts
The config includes ROG-specific keyboard scripts. You may want to:
- Comment out lines 217-221 (ASUS keyboard bindings)
- Remove/modify lines 172-176 (ASUS function keys)

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

## Next Steps

1. ✅ Deploy basic Hyprland config
2. 🔧 Customize for Macbook Pro hardware
3. 🎨 Tweak theme colors and animations
4. 📦 Add more configs as needed
5. 🚀 Enjoy your rice!

---

**Note:** This is designed for ROG Zephyrus G15 but easily adaptable for Macbook Pro. Main changes needed are monitor settings, keyboard layouts, and removing ASUS-specific scripts.

🍸 **Добро пожаловать, командир!**
