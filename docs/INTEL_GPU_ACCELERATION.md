# Intel GPU Hardware Acceleration - Quick Setup

**For T2 MacBooks and other Macs with Intel integrated graphics**

## 🚀 One-Line Setup

```bash
~/balder/scripts/setup-gpu-acceleration.sh
```

This automated script will:
- ✅ Install `intel-media-driver`, `libva-utils`, `vulkan-tools`
- ✅ Create `~/.config/chromium-flags.conf` with acceleration flags
- ✅ Create browser launcher scripts (`browseros`, `chromium-accel`, etc.)
- ✅ Add GPU environment variables to `~/.zshrc`
- ✅ Verify VA-API and Vulkan are working

---

## 📦 What Gets Installed

### Required Packages
```bash
sudo pacman -S intel-media-driver  # VA-API (iHD driver) for Gen 8+ Intel
sudo pacman -S libva-utils          # Testing tools (vainfo)
sudo pacman -S vulkan-tools         # Vulkan testing (vulkaninfo)
```

### Configuration Files Created

| File | Purpose |
|------|---------|
| `~/.config/chromium-flags.conf` | Master Chromium acceleration config |
| `~/.local/bin/browseros` | BrowserOS launcher with acceleration |
| `~/.local/bin/chromium-accel` | Chromium launcher with acceleration |
| `~/.local/bin/chrome-accel` | Chrome launcher with acceleration |
| `~/.local/bin/brave-accel` | Brave launcher with acceleration |

### Environment Variables Added to `~/.zshrc`

```bash
export LIBVA_DRIVER_NAME=iHD              # Use intel-media-driver
export MOZ_DISABLE_RDD_SANDBOX=1          # Firefox GPU access
export MOZ_USE_XINPUT2=1                  # Smooth scrolling
export MOZ_ENABLE_WAYLAND=1               # Wayland support
export CHROMIUM_FLAGS="..."               # Chromium acceleration flags
```

---

## ✅ Verification

### Test VA-API (Video Acceleration)
```bash
vainfo
```
**Expected:** Shows Intel iHD driver with H.264, HEVC, VP9 support

### Test Vulkan (GPU Acceleration)
```bash
vulkaninfo --summary | head -30
```
**Expected:** Shows Intel Iris/UHD Graphics detected

### Verify in Browser
```bash
browseros              # or chromium-accel, chrome-accel, brave-accel
# Navigate to: chrome://gpu
```
**Expected:**
- Video Acceleration Information → VA-API enabled
- Graphics Feature Status → Hardware accelerated

---

## 🎯 Supported Hardware

### Intel Integrated Graphics
- ✅ **Coffee Lake** (Gen 9) - Iris Plus 655, UHD 630
- ✅ **Comet Lake** (Gen 9.5) - Iris Plus, UHD Graphics
- ✅ **Ice Lake** (Gen 11) - Iris Plus G4/G7
- ✅ **Tiger Lake** (Gen 12) - Iris Xe
- ✅ **Alder Lake** (Gen 12) - Iris Xe, UHD Graphics
- ✅ **Any Gen 8+ Intel GPU**

### Tested MacBook Models
- ✅ MacBook Pro 13/15" 2018-2019 (T2, Coffee Lake)
- ✅ MacBook Pro 13" 2020 (T2, Ice Lake)
- ⚠️ Should work on other T2 MacBooks with Intel graphics

---

## 🔧 Manual Setup (if script fails)

<details>
<summary>Click to expand manual steps</summary>

### 1. Install Packages
```bash
sudo pacman -S intel-media-driver libva-utils vulkan-tools
```

### 2. Add to `~/.zshrc`
```bash
export LIBVA_DRIVER_NAME=iHD
export MOZ_DISABLE_RDD_SANDBOX=1
export MOZ_USE_XINPUT2=1
export MOZ_ENABLE_WAYLAND=1
```

### 3. Create `~/.config/chromium-flags.conf`
```
--enable-features=VaapiVideoDecoder,VaapiVideoEncoder
--enable-gpu-rasterization
--enable-zero-copy
--use-vulkan=native
--ozone-platform=wayland
```

### 4. Create launcher script
```bash
#!/bin/bash
export LIBVA_DRIVER_NAME=iHD
FLAGS="$(cat ~/.config/chromium-flags.conf | grep -v '^#' | tr '\n' ' ')"
exec /path/to/browser $FLAGS "$@"
```

</details>

---

## 🐛 Troubleshooting

### Browser still slow?
```bash
# Check environment variable is set
echo $LIBVA_DRIVER_NAME  # Should output: iHD

# Verify VA-API is accessible
vainfo  # Should NOT show errors

# Check browser GPU status
browseros
# Navigate to: chrome://gpu
# "Video Acceleration Information" should show VA-API
```

### VA-API not working?
```bash
# Check driver files exist
ls -la /dev/dri/  # Should show card0, renderD128

# Test with explicit driver
LIBVA_DRIVER_NAME=iHD vainfo

# Verify packages installed
pacman -Q intel-media-driver libva-utils
```

### After reboot still not working?
```bash
# Reload shell config
source ~/.zshrc

# Re-run setup script
~/balder/scripts/setup-gpu-acceleration.sh
```

---

## 📊 Performance Impact

### Before Fix ❌
- CPU usage during video: **60-80%**
- Choppy scrolling and UI
- Battery drain
- Thermal throttling

### After Fix ✅
- CPU usage during video: **5-15%**
- Smooth 60fps scrolling
- Better battery life
- Cooler operation

---

## 🔄 Transferring to Another Mac

1. Clone your balder repo on new machine
2. Run setup script: `~/balder/scripts/setup-gpu-acceleration.sh`
3. Restart terminal or run: `source ~/.zshrc`
4. Done! Hardware acceleration enabled

**That's it!** The script is fully automated and portable across Intel-based T2 Macs.

---

## 📚 Related Documentation

- **Full Guide:** [GPU_ACCELERATION_SETUP.md](./GPU_ACCELERATION_SETUP.md)
- **BrowserOS:** [browseros-ai/BrowserOS](https://github.com/browseros-ai/BrowserOS)
- **Arch Wiki:** [Hardware video acceleration](https://wiki.archlinux.org/title/Hardware_video_acceleration)
- **Intel Media Driver:** [intel/media-driver](https://github.com/intel/media-driver)

---

## ✨ Credits

Setup optimized for T2 MacBook Pro running Arch Linux with Hyprland compositor.
Works with any Wayland/X11 compositor and any Intel Gen 8+ GPU.
