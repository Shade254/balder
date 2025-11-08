# Hyprland Config 

───────────────────────────────────────────────  
 °˖* ૮( • ᴗ ｡)っ🍸 shheersh - Dionysus vers. 1.0   
 ───────────────────────────────────────────────  
 
## Custom **hyprland** config
Tuned for EWW integration, CAVA visualizer, and Waybar  
![Hyprland Demo](../../assets/demo-hypr.gif)  
---

##  Features
  - Dynamic waybar depending on active/inactive windows.
  - Firefox preload for smooth quick access.
  - MacBook Pro T2 hardware integration – power management, keyboard backlight, breathing effects

![Hyprland Demo 2](../../assets/demo-hypr-2.gif)

```
hyprland/
├── hyprland.conf
├── scripts/
│   ├── waybar_watcher.sh
│   ├── t2-power/
│   │   └── cycle-power-mode.sh
│   └── t2-kbd/
│       └── kbd-breathing.sh
└── demo.gif
```

## Requirements
  - **Hyprland** (Wayland compositor & WM)
  - **Hyprpaper** (wallpaper daemon for Hyprland)
  - **eww** (Elkowar’s Wacky Widgets)
  - **cava** (audio visualizer)
  - **rofi** (application launcher)
  - **alacritty** (terminal emulator)
  - **thunar** (file manager)
  - **firefox** (browser, with custom profile support)
  - **grim** (Wayland screenshot tool)
  - **slurp** (Wayland region selector)
  - **wl-clipboard** (for `wl-copy`)
  - **wpctl** (PipeWire volume control)
  - **playerctl** (media player control)
  - **brightnessctl** (backlight control)
  - **curl** (network requests in scripts)
  - **lm-sensors** (for temps, fans, voltages)

This config ties into your other dotfiles:

## Usage

- **Waybar/Eww** → via [`waybar_watcher.sh`](https://github.com/pewdiepie-archdaemon/dionysus/blob/dionysus/dotfiles/hypr/scripts/waybar_watcher.sh)
  Keeps Waybar and EWW and hyprpaper running reliably under Hyprland.
- **CAVA Visualizer** → launched on login, outputs ASCII to `/tmp/cava.raw`
  Integrated with EWW via [`audio_visualizer.py`](https://github.com/pewdiepie-archdaemon/dionysus/blob/dionysus/dotfiles/eww/).

## MacBook Pro 2018 T2 Configuration

This configuration is optimized for MacBook Pro 2018 with T2 chip running Arch Linux (linux-t2 kernel).

### Power Management
- **Intel EPP** (Energy Performance Preference) for CPU power management
- **F5**: Cycle power profiles (REACTOR SLEEP → STABILIZATION → RAZGON)
- **Waybar widget**: Shows current power mode with nuclear theme colors

### Keyboard Backlight
- **F3**: Decrease keyboard backlight brightness
- **F4** (above F3): Increase keyboard backlight brightness
- **F4** (XF86Launch3): Toggle breathing effect

### Hardware Support
- ✅ Keyboard backlight (`apple::kbd_backlight` device)
- ✅ Intel CPU frequency scaling (P-State driver with EPP)
- ✅ Display brightness (native function keys)
- ✅ TouchPad gestures
- ❌ Touch ID (not supported on Linux)
- ❌ FaceTime camera (driver limitations)

### Requirements
- linux-t2 kernel (6.11+ recommended)
- brightnessctl for keyboard backlight
- Udev rules for EPP and keyboard backlight permissions (see `../system/`)

### Installation
1. Deploy dotfiles: `./deploy.sh`
2. Install udev rules: `sudo cp dotfiles/system/*.rules /etc/udev/rules.d/ && sudo udevadm control --reload`
3. Reload Hyprland: `hyprctl reload`

