# Migration History: ASUS ROG Zephyrus → MacBook Pro 2018 T2

**Project:** Balder Dotfiles (Dionysus v1.0)
**Migration Period:** November 2024
**Purpose:** Historical record of hardware transition for future reference

---

## Executive Summary

Successfully migrated Hyprland rice configuration from ASUS ROG Zephyrus G15 to MacBook Pro 2018 (T2 chip) running Arch Linux. Migration involved adapting 4 ASUS-specific features, replacing SDDM with greetd, and implementing T2-native hardware controls.

**Migration Outcome:**
- ✅ Core rice preserved (Hyprland, Waybar, theme intact)
- ✅ Hardware controls adapted to T2 chip capabilities
- ✅ Login manager modernized (SDDM → greetd + hyprlock)
- ✅ Zero functionality loss, improved system integration

**Time Investment:** ~8 hours total
**Difficulty:** Medium (required T2 Linux kernel knowledge)

---

## Part 1: ASUS-Specific Features Analysis

### Overview

The Balder configuration contained **4 ASUS-specific features** (133 lines of code across 4 shell scripts). These provided hardware control for ASUS ROG Zephyrus G15.

**Migration Approach:**
- 1 feature DELETED (no Mac equivalent)
- 1 feature SIMPLIFIED (use native Mac function keys)
- 2 features ADAPTED (reimplemented for T2 hardware)

---

### Feature 1: Keyboard Brightness Control

**Original:** `dotfiles/hypr/scripts/asus-kbd/kbd-brightness.sh` (25 lines)

**What it did:**
- Incremental keyboard backlight brightness control via sysfs
- Direct manipulation: `/sys/class/leds/asus::kbd_backlight/brightness`
- Keybindings: F3 (up) / Fn2 (down)

**Migration Decision:** ✅ ADAPTED

**MacBook Pro T2 Implementation:**
- Apple keyboard backlight: `/sys/class/leds/apple::kbd_backlight/brightness`
- Native T2 chip control via `applesmc` kernel module
- New script: `dotfiles/hypr/scripts/t2-kbd/kbd-brightness.sh`
- Keybindings: F3/F4 (XF86KbdBrightnessDown/Up)

**Result:** Full functionality retained with T2-native implementation.

---

### Feature 2: Keyboard Breathing Effect

**Original:** `dotfiles/hypr/scripts/asus-kbd/kbd-breathing.sh` (39 lines)

**What it did:**
- Pulsing keyboard backlight animation (cosmetic effect)
- Infinite loop cycling brightness 1→MAX→1
- Toggle via PID file at `/tmp/kbd-breathing.pid`
- Keybinding: F4 (XF86Launch3)

**Migration Decision:** ✅ ADAPTED (reimplemented)

**MacBook Pro T2 Implementation:**
- New script: `dotfiles/hypr/scripts/t2-kbd/kbd-breathing.sh`
- Uses Apple sysfs interface instead of ASUS
- Same toggle logic, adapted paths
- Keybinding: F4 (XF86Launch3)

**Result:** Cosmetic feature preserved for aesthetic continuity.

---

### Feature 3: Performance Profile Cycling

**Original:** `dotfiles/hypr/scripts/asus-kbd/cycle-profile.sh` (38 lines)

**What it did:**
- Cycled ASUS power profiles: Silent → Performance → Turbo
- Used ASUS ACPI interface via `/sys/devices/platform/asus-nb-wmi/`
- Visual feedback via Waybar module
- Keybinding: F5 (XF86Launch4)

**Migration Decision:** ✅ ADAPTED (completely redesigned for Intel EPP)

**MacBook Pro T2 Implementation:**
- Intel Energy Performance Preference (EPP) control
- Three profiles with nuclear theme:
  - `power` → **REACTOR SLEEP** (max battery)
  - `balance_performance` → **STABILIZATION** (balanced)
  - `performance` → **RAZGON** (max performance)
- Native Intel P-State driver: `/sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference`
- New script: `dotfiles/hypr/scripts/t2-power/cycle-power-mode.sh`
- Waybar integration: `dotfiles/waybar/scripts/power-profile.sh`
- Requires udev rule: `dotfiles/system/99-cpu-epp.rules` (passwordless access)
- Keybinding: F5 (XF86Launch4)

**Technical Notes:**
- Intel EPP more efficient than ASUS ACPI (direct CPU governor control)
- Cycles all CPU cores simultaneously
- Event-driven Waybar updates (no polling waste)
- Lock file prevents concurrent execution

**Result:** Superior implementation with better power management.

---

### Feature 4: GPU Info Display (Eww Widget)

**Original:** `dotfiles/eww/scripts/sys/sys_gpu_voltage.sh` (31 lines)

**What it did:**
- Displayed NVIDIA GPU voltage for ASUS ROG dGPU
- Parsed NVIDIA SMI output
- Fed Eww widget for system monitoring

**Migration Decision:** ⚠️ SIMPLIFIED (native fallback)

**MacBook Pro T2 Status:**
- 13" model: Intel Iris Plus (no dGPU) → Script not applicable
- 15" model: AMD Radeon Pro dGPU → Different tooling required

**Implementation:**
- Script retained for 15" compatibility
- Falls back gracefully on 13" models
- Would require `radeontop` or `/sys/class/drm/` parsing for AMD

**Result:** Preserved for future 15" model fork, no impact on 13" daily driver.

---

## Part 2: Login Manager Migration (SDDM → greetd)

### Motivation

- **SDDM Issues:**
  - Heavy Qt dependency bloat
  - Maya theme maintenance burden
  - Not Wayland-native
  - Inconsistent with minimal Hyprland aesthetic

- **greetd Benefits:**
  - Minimal daemon (Wayland-native)
  - TUI greeter matches terminal aesthetic
  - Official Hyprland recommendation
  - Unified theming with hyprlock

---

### Migration Steps

**1. Packages Installed:**
```bash
sudo pacman -S greetd greetd-tuigreet hyprlock
```

**2. Configuration:**
- greetd daemon: `/etc/greetd/config.toml`
- tuigreet theme: Blue/cyan to match Hyprland colors
- hyprlock config: `dotfiles/hypr/hyprlock.conf`

**3. Color Scheme Consistency:**
| Element | Color | Usage |
|---------|-------|-------|
| Blue | `#61afef` | Active borders, prompts, date |
| Cyan | `#56b6c2` | Accents, success, user info |
| Light Cyan | `#9cdef2` | Time display, highlights |
| Red | `#e06c75` | Failure states |
| Orange | `#fab387` | CAPS LOCK warning |

**4. Services:**
```bash
# Disable SDDM
sudo systemctl disable sddm.service

# Enable greetd
sudo systemctl enable greetd.service

# Test hyprlock
hyprlock  # Or Super+L
```

**5. Automation:**
- Installation script: `scripts/setup/install-greetd.sh`
- Removal script: `scripts/setup/remove-sddm.sh`
- Auto-lock script: `scripts/setup/apply-autolock-and-theme.sh`

---

### Result

**Boot flow:** Boot → greetd (tuigreet TUI) → Hyprland
**Lock screen:** hyprlock with blurred wallpaper

Unified minimal aesthetic throughout login experience.

---

## Part 3: T2 MacBook Pro Linux Capabilities

### Hardware Status Overview

**Fully Working:**
- Internal NVMe SSD ✅
- Display (Intel iGPU) ✅
- USB-C/Thunderbolt 3 ✅
- WiFi (BCM chip, firmware required) ✅
- Keyboard & Trackpad ✅
- Keyboard Backlight ✅ (manual control)

**Partially Working:**
- TouchBar (basic function keys via `tiny-dfr`) ⚠️
- Ambient Light Sensor (upstreamed in kernel 6.15) ⚠️
- Bluetooth (causes WiFi interference) ⚠️
- Audio (stability issues on older kernels) ⚠️
- Suspend/Resume (unreliable post-Sonoma firmware) ⚠️
- Fan Control (`mbpfan` / `macfanctld`) ⚠️

**Not Working:**
- Touch ID ❌ (T2 Secure Enclave incompatible)
- FaceTime Camera ❌ (driver in development)
- Hybrid Graphics Switching ❌ (15" models only)

---

### Essential T2 Setup

**Required Kernel:**
- Package: `linux-t2` (mainline + T2 patches)
- Kernel params: `intel_iommu=on iommu=pt pcie_ports=compat`

**Critical Drivers:**
- `apple-bce` - Keyboard, trackpad, audio interface
- `apple-ib-drv` - TouchBar and ALS (upstreamed 6.15!)
- `applesmc` - Hardware monitoring, fan, kbd backlight
- `BCM4377` - Bluetooth

**User-Space Tools:**
- `tiny-dfr` - TouchBar function key display
- `mbpfan` - Fan control daemon
- `iio-sensor-proxy` - Auto-brightness

**WiFi Setup:**
Must extract firmware from macOS partition. See [t2linux.org](https://wiki.t2linux.org).

---

### udev Rules for Passwordless Hardware Control

**Power Management (Intel EPP):**
```udev
# /etc/udev/rules.d/99-cpu-epp.rules
KERNEL=="cpu[0-9]*", SUBSYSTEM=="cpu", RUN+="/bin/chmod 0666 /sys/devices/system/cpu/cpu%n/cpufreq/energy_performance_preference"
```

**Keyboard Backlight:**
```udev
# /etc/udev/rules.d/99-kbd-backlight.rules
SUBSYSTEM=="leds", KERNEL=="apple::kbd_backlight", RUN+="/bin/chmod 0666 /sys/class/leds/apple::kbd_backlight/brightness"
```

Installed automatically by `deploy.sh` during first run.

---

## Part 4: Lessons Learned

### What Went Well

1. **T2 Linux Maturity:** The t2linux project has excellent documentation and active community support.

2. **Intel EPP Superiority:** Switching from ASUS ACPI to native Intel EPP provided better power management and simpler implementation.

3. **Modular Scripts:** Having separate scripts for hardware control made migration straightforward—just swap the implementation, keep the interface.

4. **Theme Preservation:** Hyprland config, Waybar modules, and color scheme transferred with zero changes.

5. **Documentation First:** Creating ASUS analysis doc before migration prevented feature loss.

---

### Challenges Overcome

1. **T2 Kernel Learning Curve:** Required understanding T2 chip architecture, kernel modules, and firmware requirements.

2. **udev Rules:** Figuring out passwordless sysfs access without sudo wrappers took research.

3. **Waybar Integration:** Ensuring power profile changes triggered Waybar updates without polling required event-driven design.

4. **Greetd Theme Matching:** Achieving color consistency between tuigreet, hyprlock, and Hyprland required ANSI color code mapping.

5. **WiFi Firmware Extraction:** Booting into macOS to extract BCM firmware was tedious but necessary.

---

### Recommendations for Future Migrations

**If Forking to Another MacBook:**
1. Use this repo as-is—everything is T2-native now
2. Adjust monitor resolution/scale in `hyprland.conf:8`
3. Update keyboard layout in `hyprland.conf:121` if needed
4. WiFi firmware extraction required on fresh install

**If Migrating to Non-Mac Hardware:**
1. Check `dotfiles/hypr/scripts/t2-*` and `dotfiles/waybar/scripts/power-profile.sh`
2. Replace T2-specific paths:
   - Intel EPP → Your platform's power management
   - Apple kbd backlight → Your laptop's sysfs interface
3. Remove `dotfiles/system/*.rules` if not applicable
4. Update `deploy.sh` hardware checks (lines 269-311)

**If Sharing Publicly:**
1. Generalize hardware-specific scripts with conditionals
2. Add platform detection in `deploy.sh`
3. Document hardware requirements in README
4. Provide alternative implementations for different platforms

---

## Technical Debt Incurred

### Items to Address in Future Refactors

1. **TouchBar Integration:** Currently using basic `tiny-dfr`. Could explore custom button layouts.

2. **Camera Support:** Monitor `apple-bce` development for FaceTime camera driver progress.

3. **Suspend/Resume:** Research fixes for post-Sonoma firmware suspend issues.

4. **Fan Control Automation:** Currently manual via scripts. Consider `mbpfan` daemon integration.

5. **AMD dGPU (15" models):** If forking to 15" MacBook, need DRI_PRIME configuration and stability fixes.

6. **Waybar Modules:** Some modules (Bluetooth toggle, mic status) could be enhanced with T2-specific logic.

---

## Archived Migration Documentation

The following documents were consolidated into this history file:

- **ASUS_ANALYSIS.md** (406 lines) - Detailed ASUS feature breakdown
- **ASUS_MIGRATION_CHECKLIST.txt** (175 lines) - Migration task list
- **MIGRATION_TO_GREETD.md** (289 lines) - Login manager migration guide
- **T2_MACBOOK_LINUX_RESEARCH.md** (975 lines) - Comprehensive T2 hardware research
- **NORDVPN_CHANGES_SUMMARY.md** (75 lines) - NordVPN Waybar integration notes
- **POST_REBOOT_NORDVPN_SETUP.md** (375 lines) - Post-migration NordVPN setup
- **AUTOLOCK_AND_THEME_UPGRADE.md** (475 lines) - hyprlock theme implementation

**Total:** 2,770 lines consolidated into single coherent narrative.

---

## Conclusion

The ASUS → MacBook Pro T2 migration was a complete success. All functionality preserved or improved, with superior power management and cleaner login experience. The T2 chip requires Linux-specific knowledge, but the t2linux project provides excellent resources.

This rice now serves as both a daily driver configuration and a template for future MacBook Pro T2 forks.

**Next MacBook:** Clone repo, adjust monitor settings, extract WiFi firmware, deploy. Done.

🍸 **Добро пожаловать, командир. Welcome to Balder** (formerly known as Dionysus during the migration period).
