# 🔄 Reboot & Test Checklist - GPU Acceleration

## ✅ What Was Done (Pre-Reboot)

### Packages Installed
- ✅ `intel-media-driver` - VA-API hardware video acceleration
- ✅ `libva-utils` - VA-API testing tools
- ✅ `vulkan-tools` - Vulkan testing

### Files Created/Modified

| File | Status | Purpose |
|------|--------|---------|
| `~/balder/dotfiles/zsh/.zshrc` | ✅ Modified | Added GPU acceleration env vars |
| `~/.config/chromium-flags.conf` | ✅ Created | Chromium acceleration flags |
| `~/.local/bin/browseros` | ✅ Created | BrowserOS launcher wrapper |
| `~/.local/bin/chromium-accel` | ✅ Created | Chromium launcher |
| `~/.local/bin/chrome-accel` | ✅ Created | Chrome launcher |
| `~/.local/bin/brave-accel` | ✅ Created | Brave launcher |
| `~/balder/scripts/setup-gpu-acceleration.sh` | ✅ Created | Auto-setup script for other machines |
| `~/balder/docs/GPU_ACCELERATION_SETUP.md` | ✅ Created | Full documentation |
| `~/balder/docs/INTEL_GPU_ACCELERATION.md` | ✅ Created | Quick reference guide |

### Environment Variables Added
```bash
export LIBVA_DRIVER_NAME=iHD              # Intel media driver
export MOZ_DISABLE_RDD_SANDBOX=1          # Firefox GPU access
export MOZ_USE_XINPUT2=1                  # Smooth scrolling
export MOZ_ENABLE_WAYLAND=1               # Wayland support
export CHROMIUM_FLAGS="..."               # Chromium flags
```

---

## 🚀 Post-Reboot Test Plan

### Step 1: Verify Environment (2 min)

```bash
# Open terminal and verify env vars loaded
echo $LIBVA_DRIVER_NAME
# Expected: iHD

echo $MOZ_ENABLE_WAYLAND
# Expected: 1

# Verify path includes .local/bin
echo $PATH | grep ".local/bin"
# Expected: Should show /home/miro/.local/bin
```

**✅ PASS:** Environment variables are loaded
**❌ FAIL:** Run `source ~/.zshrc` and re-check

---

### Step 2: Test VA-API Driver (1 min)

```bash
vainfo
```

**Expected Output:**
```
vainfo: VA-API version: 1.22 (libva 2.22.0)
vainfo: Driver version: Intel iHD driver for Intel(R) Gen Graphics - 25.3.4

Supported profiles:
  VAProfileH264Main
  VAProfileH264High
  VAProfileHEVCMain
  VAProfileHEVCMain10
  VAProfileVP9Profile0
  ...
```

**✅ PASS:** Shows Intel iHD driver with codec support
**❌ FAIL:** Check if `intel-media-driver` is installed: `pacman -Q intel-media-driver`

---

### Step 3: Test Vulkan (1 min)

```bash
vulkaninfo --summary | head -30
```

**Expected Output:**
```
GPU0:
  deviceName         = Intel(R) Iris(R) Plus Graphics 655 (CFL GT3)
  deviceType         = PHYSICAL_DEVICE_TYPE_INTEGRATED_GPU
  driverName         = Intel open-source Mesa driver
```

**✅ PASS:** Shows Intel GPU detected
**❌ FAIL:** Check if `vulkan-intel` is installed: `pacman -Q vulkan-intel`

---

### Step 4: Launch BrowserOS with Acceleration (2 min)

```bash
browseros
```

**In BrowserOS:**
1. Navigate to: `chrome://gpu`
2. Scroll down to check key sections

**Expected Results:**

#### Graphics Feature Status
- **Canvas**: Hardware accelerated
- **Canvas out-of-process rasterization**: Enabled
- **Compositing**: Hardware accelerated
- **Multiple Raster Threads**: Enabled
- **Rasterization**: Hardware accelerated on all threads
- **Video Decode**: Hardware accelerated
- **Vulkan**: Enabled

#### Video Acceleration Information
```
Decode h264 baseline    [up to 4096x4096 pixels]
Decode h264 main        [up to 4096x4096 pixels]
Decode h264 high        [up to 4096x4096 pixels]
Decode hevc main        [up to 8192x8192 pixels]
Decode hevc main 10     [up to 8192x8192 pixels]
Decode vp8              [up to 4096x4096 pixels]
Decode vp9 profile0     [up to 8192x8192 pixels]
```

**✅ PASS:** Video acceleration shows VA-API enabled
**❌ FAIL:** Flags not loading - check wrapper script exists: `ls -la ~/.local/bin/browseros`

---

### Step 5: Real-World Performance Test (5 min)

#### Test 1: YouTube Video
1. Open YouTube in BrowserOS
2. Play a 4K video (or 1080p60 if 4K unavailable)
3. Open `htop` in another terminal
4. Monitor CPU usage

**Expected Results:**
- **Before fix:** CPU 60-80% usage, stuttering
- **After fix:** CPU 5-15% usage, smooth playback

**✅ PASS:** Low CPU, smooth video
**❌ FAIL:** High CPU usage - acceleration not working

#### Test 2: Smooth Scrolling
1. Open a content-heavy site (Reddit, Twitter/X)
2. Scroll rapidly up and down

**Expected Results:**
- **Before fix:** Choppy scrolling, lag
- **After fix:** Buttery smooth 60fps scrolling

**✅ PASS:** Smooth scrolling
**❌ FAIL:** Choppy - check GPU rendering in `chrome://gpu`

#### Test 3: Multiple Tabs with Video
1. Open 3-4 YouTube tabs
2. Play videos in each
3. Monitor CPU with `htop`

**Expected Results:**
- **Before fix:** CPU 90-100%, thermal throttling
- **After fix:** CPU 20-40%, cool operation

**✅ PASS:** Can handle multiple videos
**❌ FAIL:** System struggles - acceleration not working

---

## 🎯 Success Criteria

### Minimum Requirements (Must Pass)
- ✅ Environment variables loaded (`LIBVA_DRIVER_NAME=iHD`)
- ✅ VA-API shows Intel iHD driver
- ✅ `chrome://gpu` shows Video Acceleration enabled
- ✅ YouTube video plays with <20% CPU usage

### Optimal Results (Should Pass)
- ✅ Vulkan enabled in browser
- ✅ Smooth 60fps scrolling
- ✅ Can handle 3+ video tabs simultaneously
- ✅ No thermal throttling during normal browsing

---

## 🐛 If Tests Fail

### Environment variables not loaded
```bash
# Reload shell config
source ~/.zshrc

# Or restart terminal completely
```

### VA-API not working
```bash
# Check driver installation
pacman -Q intel-media-driver

# Re-run setup script
~/balder/scripts/setup-gpu-acceleration.sh
```

### BrowserOS not launching with flags
```bash
# Check wrapper script exists and is executable
ls -la ~/.local/bin/browseros
cat ~/.local/bin/browseros

# Verify flags config exists
cat ~/.config/chromium-flags.conf

# Test manual launch
LIBVA_DRIVER_NAME=iHD ~/.local/opt/browseros/BrowserOS.AppImage --enable-features=VaapiVideoDecoder
```

### Still experiencing poor performance
```bash
# Check if another driver is interfering
env | grep -E "LIBVA|VDPAU|MESA"

# Verify kernel driver loaded
lsmod | grep i915

# Check GPU power state
cat /sys/class/drm/card0/device/power/runtime_status
```

---

## 📊 Expected Performance Metrics

### Before vs After

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| YouTube 1080p CPU | 60-80% | 5-15% | **75% reduction** |
| Scrolling FPS | ~30fps | ~60fps | **2x smoother** |
| Battery life | ~3-4hrs | ~5-7hrs | **~50% longer** |
| Thermals | Hot/throttling | Cool/quiet | **Much cooler** |
| Multi-tab handling | Struggles | Smooth | **Much better** |

---

## 📝 Post-Test Documentation

After testing, update this document with your actual results:

```markdown
## Test Results - [DATE]

### Hardware
- Model: MacBook Pro [YOUR MODEL]
- CPU: [YOUR CPU]
- GPU: Intel Iris Plus 655

### Test Results
- VA-API: [PASS/FAIL]
- Vulkan: [PASS/FAIL]
- BrowserOS GPU page: [PASS/FAIL]
- YouTube performance: [PASS/FAIL]
- CPU usage during 1080p video: [X%]
- Scrolling smoothness: [PASS/FAIL]

### Notes
[Any observations or issues encountered]
```

---

## 🎉 Success Indicators

If you see these, YOU'VE WON:

1. ✅ `vainfo` shows Intel iHD driver with full codec support
2. ✅ `chrome://gpu` shows "Video Decode: Hardware accelerated"
3. ✅ YouTube plays smoothly with CPU <20%
4. ✅ Scrolling is buttery smooth
5. ✅ System stays cool during normal browsing
6. ✅ Battery life noticeably improved

**That's when you know the GPU is actually doing its job!** 🚀

---

## 🔄 Transferring to Another Mac

When you get a new T2 MacBook with Intel GPU:

```bash
# Clone balder repo
git clone [your-repo-url] ~/balder

# Run automated setup
~/balder/scripts/setup-gpu-acceleration.sh

# Restart terminal
source ~/.zshrc

# Test
browseros
# Go to chrome://gpu and verify
```

**Done!** The entire setup is now portable and repeatable.
