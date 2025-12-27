# Hyprland Config 

───────────────────────────────────────────────  
 °˖* ૮( • ᴗ ｡)っ🍸 shheersh - Balder v1.0   
 ───────────────────────────────────────────────  
 
## Custom **hyprland** config
Tuned for EWW integration and Waybar  
![Hyprland Demo](../../assets/demo-hypr.gif)  
---

##  Features
  - Dynamic waybar depending on active/inactive windows.
  - Firefox preload for smooth quick access.
  - MacBook Pro T2 hardware integration – power management, keyboard backlight, breathing effects

![Hyprland Demo 2](../../assets/demo-hypr-2.gif)

```
hypr/
├── hyprland.conf           # Main Hyprland config
├── hyprpaper.conf          # Wallpaper daemon config
├── hyprlock.conf           # Lock screen config
├── hyprlock/               # hyprlock themes and assets
├── wallpapers/             # Background images
└── scripts/
    ├── waybar_watcher.sh   # EWW/Waybar toggle based on window state
    ├── refresh-eww.sh      # Reload EWW widgets
    ├── screenshot.sh       # Screenshot utility with region selection
    ├── lock-screen.sh      # Lock screen wrapper
    ├── lock-with-dpms.sh   # Lock + display power management
    ├── start-swayidle.sh   # Idle timeout configuration
    ├── wake-all-displays.sh # Wake monitors from sleep
    ├── boot-monitors-init.sh # Multi-monitor initialization
    ├── capslock-status.sh  # CAPS LOCK indicator
    ├── speech-toggle.sh    # Toggle speech-to-text (F6)
    ├── speech-start.sh     # Start speech daemon
    ├── speech-stop.sh      # Stop speech daemon
    ├── speech-daemon.py    # Whisper AI transcription service
    ├── t2-power/
    │   └── cycle-power-mode.sh  # Intel EPP power profile cycling
    └── t2-kbd/
        ├── kbd-brightness.sh    # Keyboard backlight control
        └── kbd-breathing.sh     # Breathing effect toggle
```

## Requirements
  - **Hyprland** (Wayland compositor & WM)
  - **Hyprpaper** (wallpaper daemon for Hyprland)
  - **eww** (Elkowar's Wacky Widgets)
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

- **Waybar/Eww** → via [`waybar_watcher.sh`](scripts/waybar_watcher.sh)
  Keeps Waybar and EWW and hyprpaper running reliably under Hyprland.

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

### Speech-to-Text (Whisper AI)
- **F6**: Toggle speech-to-text dictation
- Uses OpenAI Whisper for local transcription
- Audio recorded via PipeWire, transcribed text typed via `wtype`
- See [docs/SPEECH_TO_TEXT_SETUP.md](../../docs/SPEECH_TO_TEXT_SETUP.md) for setup

### Requirements
- linux-t2 kernel (6.11+ recommended)
- brightnessctl for keyboard backlight
- Udev rules for EPP and keyboard backlight permissions (see `../system/`)
- For speech-to-text: whisper, wtype, pipewire

### Installation
1. Deploy dotfiles: `./deploy.sh`
2. Install udev rules: `sudo cp dotfiles/system/*.rules /etc/udev/rules.d/ && sudo udevadm control --reload`
3. Reload Hyprland: `hyprctl reload`

