# Quickstart: Fork Balder for Your Machine

**Target Audience:** You want to use this Hyprland rice on your own hardware
**Time Required:** 30-60 minutes (depending on hardware)
**Skill Level:** Intermediate Linux user comfortable with Arch, git, and shell scripts

---

## What is Balder?

A production-ready Hyprland rice configuration featuring:
- ✨ **Minimal aesthetic** - Nord-inspired neon-radioactive theme with blue/cyan accents
- ⚡ **Event-driven design** - Zero polling, pure event-based Waybar updates
- 🎛️ **Hardware integration** - Power profiles, keyboard backlight, hardware controls
- 🔒 **Unified login** - greetd + hyprlock with matching theme
- 📦 **Modular installation** - Install only what you need

Originally built for MacBook Pro 2018 T2, designed to be easily portable.

---

## Quick Decision Tree

**Are you running a MacBook Pro 2018 with T2 chip?**
- ✅ **YES** → This config works out-of-the-box! Skip to [MacBook Pro T2 Installation](#macbook-pro-t2-installation)
- ❌ **NO** → Continue reading for adaptation guide

**What's your hardware?**
- 🍎 **MacBook Pro (older/newer)** → See [Other MacBooks](#adapting-for-other-macbooks)
- 💻 **Generic laptop (Dell, Lenovo, etc.)** → See [Generic Hardware](#adapting-for-generic-hardware)
- 🖥️ **Desktop** → See [Desktop Adaptation](#adapting-for-desktop)

---

## MacBook Pro T2 Installation

### Prerequisites

✅ **Arch Linux with T2 kernel installed**
- If not: Follow [t2linux.org installation guide](https://wiki.t2linux.org)
- Required kernel: `linux-t2` (mainline + T2 patches)
- Required params: `intel_iommu=on iommu=pt pcie_ports=compat`

✅ **WiFi firmware extracted from macOS**
- See t2linux docs for BCM firmware extraction

✅ **Basic Hyprland dependencies**
- Will be installed by script if missing

### Installation Steps

```bash
# 1. Clone the repository
git clone https://github.com/YOUR_USERNAME/balder.git ~/balder
cd ~/balder

# 2. Install dependencies (interactive mode - choose what you need)
./install.sh

# Or install everything at once:
./install.sh --all

# 3. Deploy dotfiles
./deploy.sh

# 4. Reboot to apply all changes
sudo reboot
```

### What Happens During Installation

**install.sh** will:
- Check for Arch Linux
- Offer modular installation (core, waybar, terminal, appearance, extras)
- Install packages via pacman
- Enable system services (Bluetooth, etc.)

**deploy.sh** will:
- Create backups of existing configs (saved to `~/.dotfiles-backup-TIMESTAMP/`)
- Symlink dotfiles from repo to `~/.config/`
- Install T2 udev rules for passwordless hardware control
- Reload Hyprland, Waybar, and hyprpaper
- Verify services are running

### Post-Installation

**Test your setup:**
```bash
# Power profile cycling (F5 or XF86Launch4)
# Should cycle: REACTOR SLEEP → STABILIZATION → RAZGON

# Keyboard backlight (F3/F4)
# Should adjust brightness up/down

# Screen lock (Super+L)
hyprlock
```

**Customize for your setup:**
1. **Monitor config:** Edit `dotfiles/hypr/hyprland.conf:8`
   ```conf
   monitor = eDP-1, preferred, auto, 1.25  # Adjust scale for your display
   ```

2. **Keyboard layout:** Edit `dotfiles/hypr/hyprland.conf:121`
   ```conf
   kb_layout = gb, se  # Change to your layouts
   ```

3. **Firefox profile:** Edit `dotfiles/hypr/hyprland.conf:20` (if using custom Firefox profile)

**You're done!** 🍸

---

## Adapting for Other MacBooks

### MacBook Pro (Intel, non-T2)

**What works out-of-box:**
- Core Hyprland config ✅
- Waybar modules ✅
- Theme and aesthetics ✅
- Terminal setup ✅

**What needs adaptation:**
- **Keyboard backlight:** Change sysfs path in `dotfiles/hypr/scripts/t2-kbd/*.sh`
  - Find your path: `ls /sys/class/leds/`
  - Update scripts to match

- **Power profiles:** If Intel CPU, keep `cycle-power-mode.sh`
  - If AMD: Replace with `ryzenadj` or ACPI controls

- **udev rules:** Check paths in `dotfiles/system/*.rules` match your hardware

### MacBook Air / MacBook (M1/M2)

**Status:** Not compatible with Linux in traditional sense
- Use Asahi Linux instead (ARM64, different kernel)
- Hyprland works on Asahi, but hardware scripts need complete rewrite

---

## Adapting for Generic Hardware

### Step 1: Identify Your Hardware

Run these commands to understand your system:

```bash
# Check CPU type (Intel/AMD)
lscpu | grep "Vendor ID"

# Check GPU
lspci | grep VGA

# Check available sysfs interfaces
ls /sys/class/leds/          # Keyboard backlight
ls /sys/devices/system/cpu/cpu0/cpufreq/  # CPU power management

# Check input devices
ls /sys/class/input/
```

### Step 2: Adapt Hardware Control Scripts

**Power Management:**

**If Intel CPU with P-State driver:**
- Keep `dotfiles/hypr/scripts/t2-power/cycle-power-mode.sh` as-is
- Verify EPP path exists: `/sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference`
- Update `dotfiles/system/99-cpu-epp.rules` if needed

**If AMD CPU:**
- Replace with `ryzenadj` tool or ACPI controls
- Example replacement:
  ```bash
  # Use ryzenadj for power profiles
  ryzenadj --power-saving  # Silent
  ryzenadj --max-performance  # Turbo
  ```

**If other CPU:**
- Use `cpupower` or laptop-specific tools
- Update `dotfiles/waybar/scripts/power-profile.sh` to read from your power system

**Keyboard Backlight:**

Find your sysfs path:
```bash
ls /sys/class/leds/
# Common paths:
# - /sys/class/leds/tpacpi::kbd_backlight (ThinkPad)
# - /sys/class/leds/asus::kbd_backlight (ASUS)
# - /sys/class/leds/dell::kbd_backlight (Dell)
```

Update scripts:
- `dotfiles/hypr/scripts/t2-kbd/kbd-brightness.sh`
- `dotfiles/hypr/scripts/t2-kbd/kbd-breathing.sh`
- `dotfiles/system/99-kbd-backlight.rules`

Replace `apple::kbd_backlight` with your path.

### Step 3: Test Installation

```bash
# Install core first
./install.sh --core

# Deploy configs
./deploy.sh

# Test manually before rebooting
hyprctl reload
```

### Step 4: Remove Incompatible Features

If you don't have keyboard backlight or other features:

**Disable in Hyprland config:**
```conf
# Comment out in dotfiles/hypr/hyprland.conf
# bind = , XF86KbdBrightnessUp, exec, ~/.config/hypr/scripts/t2-kbd/kbd-brightness.sh up
```

**Remove from Waybar:**
```json
// Edit dotfiles/waybar/config - remove unsupported modules
```

---

## Adapting for Desktop

### Changes Needed

1. **Remove laptop-specific features:**
   - Keyboard backlight controls (no backlit keyboard)
   - Battery module in Waybar
   - Brightness controls (unless external monitor supports DDC/CI)

2. **Monitor configuration:**
   - Edit `dotfiles/hypr/hyprland.conf:8`
   - Configure multiple monitors if applicable:
     ```conf
     monitor = DP-1, 2560x1440@144, 0x0, 1
     monitor = HDMI-A-1, 1920x1080@60, 2560x0, 1
     ```

3. **Power profiles:**
   - Desktop power management simpler (no battery optimization)
   - Consider removing profile cycling or simplifying to performance/balanced

4. **Audio:**
   - Desktop audio typically more straightforward
   - Verify Waybar audio module works with your setup

### Desktop-Specific Enhancements

Consider adding:
- **Multi-monitor workspaces:** Bind workspaces to specific monitors
- **RGB control:** If you have RGB peripherals, add OpenRGB integration
- **Hardware monitoring:** Desktop motherboard sensors (lm_sensors)

---

## Common Customization Points

### Theme Colors

All theme colors defined in:
- `dotfiles/hypr/hyprland.conf` - Border colors, window decorations
- `dotfiles/waybar/style.css` - Waybar appearance
- `dotfiles/hypr/hyprlock.conf` - Lock screen colors
- `dotfiles/alacritty/alacritty.toml` - Terminal colors

**Color scheme:** Nord-inspired with neon accents
- Blue: `#61afef`
- Cyan: `#56b6c2`
- Background: `#282c34`

### Keybindings

All keybindings in `dotfiles/hypr/hyprland.conf` (lines 140-220)

**Common changes:**
- Window manager bindings (Super+...)
- Media keys (if your keyboard differs)
- Hardware control keys (F-keys, XF86 keys)

### Waybar Modules

Enable/disable modules in `dotfiles/waybar/config`

**Available modules:**
- Workspaces
- Clock
- Battery (laptop only)
- CPU/RAM/Storage
- Audio
- Bluetooth
- Network
- Power profile
- NordVPN (if installed)

### Wallpapers

Place wallpapers in `dotfiles/hypr/wallpapers/`

Configure in `dotfiles/hypr/hyprpaper.conf`

---

## Modular Installation Options

The `install.sh` script supports modular installation:

```bash
# Install only what you need
./install.sh --core        # Minimal Hyprland
./install.sh --waybar      # Status bar + controls
./install.sh --terminal    # Alacritty + shell tools
./install.sh --appearance  # Rofi, fonts, themes
./install.sh --extras      # Eww, Cava, etc.

# Combine multiple
./install.sh --core --waybar --terminal
```

**Use case:** Forking just Waybar presets
```bash
# Install only Waybar dependencies
./install.sh --waybar

# Deploy only Waybar config
mkdir -p ~/.config
ln -s ~/balder/dotfiles/waybar ~/.config/waybar
waybar &
```

---

## Troubleshooting

### Installation fails with missing packages

**Solution:** Update your system first
```bash
sudo pacman -Syu
./install.sh --all
```

### Deployment says "missing dependencies"

**Solution:** Run install.sh first
```bash
./install.sh --all
./deploy.sh
```

### Hyprland won't start

**Check logs:**
```bash
cat ~/.config/hypr/hypr.log
```

**Common issues:**
- Monitor config wrong → Edit `hyprland.conf:8`
- GPU drivers missing → Install mesa/nvidia/amdgpu
- Wayland session not selected at login

### Waybar not showing

**Verify it's running:**
```bash
pgrep waybar
```

**Restart manually:**
```bash
killall waybar
waybar &
```

### Hardware controls don't work

**Check udev rules:**
```bash
ls /etc/udev/rules.d/99-*.rules
```

**If missing:**
```bash
sudo cp dotfiles/system/*.rules /etc/udev/rules.d/
sudo udevadm control --reload
sudo udevadm trigger
```

### Lock screen (hyprlock) doesn't work

**Test manually:**
```bash
hyprlock
```

**Check config:**
```bash
cat dotfiles/hypr/hyprlock.conf
```

---

## Getting Help

**Documentation:**
- `docs/MIGRATION_HISTORY.md` - Full hardware migration details
- `docs/SETUP.md` - Comprehensive setup guide
- `README.md` - Project overview and features

**Community Resources:**
- [Hyprland Wiki](https://wiki.hyprland.org)
- [t2linux Project](https://wiki.t2linux.org) (for MacBooks)
- [r/unixporn](https://reddit.com/r/unixporn) - Rice community

**Reporting Issues:**
- Check existing issues first
- Include: Hardware, distro, kernel version, logs
- Describe what you've already tried

---

## Next Steps After Installation

1. **Explore keybindings:** Super+? to see all bindings (if configured)
2. **Customize theme:** Edit colors in `hyprland.conf` and `waybar/style.css`
3. **Add your wallpapers:** Drop files in `dotfiles/hypr/wallpapers/`
4. **Test all hardware controls:** Power profile, brightness, audio, etc.
5. **Set up auto-lock:** Configure idle timeout in `hyprland.conf`
6. **Share your rice:** Take screenshots and post to r/unixporn!

---

## Contributing Back

Found a bug? Improved something? **Pull requests welcome!**

**Good contribution candidates:**
- Support for new hardware platforms
- Additional Waybar modules
- Theme variations
- Documentation improvements
- Installation script enhancements

**Fork, modify, share.** That's the Unix way.

🍸 **Welcome to the Balder experience. Enjoy your rice!**
