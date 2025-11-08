# Balder - Hyprland Rice for MacBook Pro T2

```
     ) ) )                     ) ) )
   ( ( (                      ( ( (
 ) ) )                       ) ) )
(~~~~~~~~~)                 (~~~~~~~~~)
 |   А   |                   |   Б   |
 |       |                   |       |
 I      _._                  I       _._
 I    /'   `\                I     /'   `\
 I   |   N   |               I    |   N   |
 f   |   |~~~~~~~~~~~~~~|    f    |    |~~~~~~~~~~~~~~|
.'    |   ||~~~~~~~~|    |  .'     |    | |~~~~~~~~|   |
'______|___||__###___|____|/'_______|____|_|__###___|___|
```

**🍸 Dionysus vers. 1.0** - Production-ready Hyprland configuration for MacBook Pro 2018 T2

[![](https://img.shields.io/badge/Hyprland-Dynamic-blue?style=flat-square&logo=wayland&logoColor=white)](https://hyprland.org)
[![](https://img.shields.io/badge/Waybar-Event_Driven-cyan?style=flat-square)](https://github.com/Alexays/Waybar)
[![](https://img.shields.io/badge/License-MIT-green?style=flat-square)](LICENSE)

---

## ✨ Features

### 🎨 Aesthetic
- **Nord-inspired theme** with neon-radioactive blue/cyan accents
- **Unified color scheme** across Hyprland, Waybar, hyprlock, and terminal
- **Minimal design** with functional beauty
- **Smooth animations** optimized for daily use

### ⚡ Performance
- **Event-driven architecture** - Zero polling, pure signal-based updates
- **Optimized for T2 chip** - Native Intel EPP power management
- **Hardware-accelerated** - GPU acceleration via Hyprland compositor
- **Lightweight** - Minimal resource footprint

### 🛠️ Hardware Integration
- **Intel EPP Power Profiles** - Three-mode cycling (REACTOR SLEEP / STABILIZATION / RAZGON)
- **Keyboard Backlight Control** - Brightness adjustment and breathing effects
- **T2-native controls** - Passwordless sysfs access via udev rules
- **Complete media controls** - Audio, brightness, playback via function keys

### 📦 Modular Design
- **Flexible installation** - Install only what you need
- **Easy customization** - Well-documented configuration files
- **Portable** - Fork-ready for other hardware platforms
- **Professional structure** - Clean separation of concerns

---

## 🚀 Quick Start

```bash
# Clone repository
git clone https://github.com/YOUR_USERNAME/balder.git ~/balder
cd ~/balder

# Install dependencies
./install.sh --all

# Deploy dotfiles
./deploy.sh

# Reboot and enjoy!
sudo reboot
```

**That's it!** Your Hyprland rice is ready.

👉 **New to this rice?** Read the [QUICKSTART Guide](docs/QUICKSTART.md)

---

## 📸 Screenshots

*(Add your screenshots here)*

### Desktop
![Desktop Screenshot](assets/demo.gif)

### Waybar
![Waybar](assets/demo-alacritty.png)

### Lock Screen
*(hyprlock screenshot)*

### Rofi Launcher
![Rofi](assets/demo-rofi.png)

---

## 🎯 What's Included

| Component | Purpose | Notes |
|-----------|---------|-------|
| **Hyprland** | Wayland compositor | Dynamic tiling with smooth animations |
| **Waybar** | Status bar | Event-driven modules, zero polling |
| **hyprlock** | Screen locker | Blurred wallpaper, matching theme |
| **greetd + tuigreet** | Login manager | Minimal TUI with blue/cyan theme |
| **Alacritty** | Terminal emulator | GPU-accelerated, Nord color scheme |
| **Rofi** | Application launcher | Wayland-native with custom theme |
| **ZSH** | Shell | Custom configuration with modern tools |
| **Neofetch** | System info | Animated fetch matching aesthetic |

---

## 💻 Compatibility

### Primary Target
- **MacBook Pro 2018 (T2 chip)** running Arch Linux with `linux-t2` kernel

### Tested On
- MacBook Pro 13" 2018 (Intel Iris Plus)
- MacBook Pro 15" 2018 (Intel + AMD Radeon Pro dGPU)

### Portable To
- Other MacBook Pro models (Intel-based)
- Generic Intel laptops (requires hardware script adaptation)
- Desktop systems (minimal changes needed)

See [QUICKSTART.md](docs/QUICKSTART.md) for adaptation guide.

---

## 📚 Documentation

| Document | Purpose | Audience |
|----------|---------|----------|
| [QUICKSTART.md](docs/QUICKSTART.md) | Fast setup guide | Users forking this rice |
| [SETUP.md](docs/SETUP.md) | Comprehensive reference | Advanced customization |
| [MIGRATION_HISTORY.md](docs/MIGRATION_HISTORY.md) | Hardware migration details | Historical reference |

---

## 🔧 Customization

### Change Theme Colors
Edit colors in these files:
- `dotfiles/hypr/hyprland.conf` - Window manager theme
- `dotfiles/waybar/style.css` - Status bar appearance
- `dotfiles/hypr/hyprlock.conf` - Lock screen colors
- `dotfiles/alacritty/alacritty.toml` - Terminal palette

### Add Wallpapers
```bash
cp ~/Pictures/wallpaper.png dotfiles/hypr/wallpapers/
# Edit dotfiles/hypr/hyprpaper.conf
```

### Adjust Keybindings
All keybindings in `dotfiles/hypr/hyprland.conf` (lines 140-220)

### Configure Monitors
```conf
# Single monitor
monitor = eDP-1, preferred, auto, 1.25

# Multiple monitors
monitor = eDP-1, 2560x1600@60, 0x0, 1.25
monitor = DP-1, 1920x1080@60, 2560x0, 1.0
```

See [SETUP.md](docs/SETUP.md) for detailed customization options.

---

## 🧩 Modular Installation

Choose exactly what you need:

```bash
# Minimal Hyprland setup
./install.sh --core

# Add status bar and controls
./install.sh --waybar

# Terminal and shell tools
./install.sh --terminal

# Theming and visual enhancements
./install.sh --appearance

# Optional widgets (Eww, Cava, etc.)
./install.sh --extras

# Or combine multiple
./install.sh --core --waybar --terminal
```

Perfect for cherry-picking specific components!

---

## 🔑 Key Features Explained

### Intel EPP Power Management

Native Intel P-State driver integration for superior power control:

- **REACTOR SLEEP** (`power`) - Maximum battery life
- **STABILIZATION** (`balance_performance`) - Daily use
- **RAZGON** (`performance`) - Maximum performance

Cycle with **F5** key. Real-time feedback in Waybar.

### Event-Driven Waybar

Zero CPU polling - all modules update via signals:
- Power profile changes → Signal via custom script
- Volume changes → PipeWire events
- Network changes → NetworkManager signals
- Battery events → upower notifications

Result: Negligible CPU usage from status bar.

### T2 Chip Integration

Full hardware support for MacBook Pro T2:
- Keyboard backlight via applesmc kernel module
- TouchBar function keys via tiny-dfr
- WiFi (BCM chip with firmware extraction)
- Bluetooth (BCM4377 driver)
- Audio (apple-t2-audio-config)

See [docs/MIGRATION_HISTORY.md](docs/MIGRATION_HISTORY.md) for T2 details.

---

## 🤝 Contributing

Contributions welcome! Areas of interest:

- **Hardware support** - Adaptations for new platforms
- **Waybar modules** - New widgets and integrations
- **Theme variations** - Alternative color schemes
- **Documentation** - Improvements and translations
- **Bug fixes** - Always appreciated

**Process:**
1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

---

## 📖 Resources

### Hyprland
- [Official Wiki](https://wiki.hyprland.org)
- [GitHub](https://github.com/hyprwm/Hyprland)

### T2 MacBook Linux Support
- [t2linux Project](https://wiki.t2linux.org)
- [t2linux Arch](https://wiki.t2linux.org/distributions/arch/installation/)

### Waybar
- [GitHub](https://github.com/Alexays/Waybar)
- [Wiki](https://github.com/Alexays/Waybar/wiki)

### Community
- [r/unixporn](https://reddit.com/r/unixporn) - Rice showcase
- [r/hyprland](https://reddit.com/r/hyprland) - Hyprland community

---

## 📜 License

MIT License - See [LICENSE](LICENSE) file for details.

Feel free to use, modify, and share!

---

## 🙏 Credits

- **Hyprland** - [vaxerski](https://github.com/vaxerski)
- **Waybar** - [Alexays](https://github.com/Alexays)
- **t2linux Project** - T2 MacBook Linux support
- **Nord Theme** - Color inspiration

---

## 🍸 Добро пожаловать, командир

**Welcome to Dionysus.** This rice represents hundreds of hours of refinement for the perfect Hyprland experience on MacBook Pro T2.

Originally built for ASUS ROG Zephyrus G15, fully migrated to T2 hardware, and now open-sourced for the community.

**Fork it. Customize it. Make it yours.**

---

**Star this repo if you found it useful!** ⭐

Questions? Open an issue. Want to share your fork? Tag me!

*Built with love, nuclear reactors, and far too much coffee.*
