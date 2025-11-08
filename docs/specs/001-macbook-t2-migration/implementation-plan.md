# Implementation Plan: MacBook T2 Migration

## Overview

This plan breaks down the migration from ASUS ROG to MacBook T2-native configuration into sequenced implementation phases with clear dependencies and validation gates.

**Estimated Effort**: 2-3 hours
**Implementation Strategy**: Incremental replacement with continuous testing
**Risk Mitigation**: Git branch, test each phase before proceeding

---

## Pre-Implementation Checklist

- [ ] Create git branch: `git checkout -b feature/t2-macbook-migration`
- [ ] Backup current working config: `./deploy.sh` output saved
- [ ] Verify system state:
  - [ ] Intel EPP available: `cat /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference`
  - [ ] Keyboard backlight exists: `ls /sys/class/leds/apple::kbd_backlight/`
  - [ ] brightnessctl working: `brightnessctl --list | grep kbd_backlight`
  - [ ] Current Hyprland/Waybar functional

---

## Phase 1: Foundation - Udev Rule & Permissions

**Goal**: Enable passwordless sysfs writes for Intel EPP

**Dependencies**: None (standalone)

**Tasks**:

1. **Create system configuration directory**
   ```bash
   mkdir -p dotfiles/system
   ```

2. **Write udev rule file**
   - File: `dotfiles/system/99-cpu-epp.rules`
   - Content:
   ```udev
   # Allow user-space writes to Intel EPP interface
   ACTION=="add|change", KERNEL=="cpu[0-9]*", SUBSYSTEM=="cpu", \
     RUN+="/bin/chmod 0666 /sys/devices/system/cpu/cpu%n/cpufreq/energy_performance_preference"
   ```

3. **Install udev rule**
   ```bash
   sudo cp dotfiles/system/99-cpu-epp.rules /etc/udev/rules.d/
   sudo udevadm control --reload
   sudo udevadm trigger
   ```

4. **Validate permissions**
   ```bash
   # Should NOT require sudo
   echo "power" > /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference
   cat /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference
   # Expected: "power"
   ```

**Validation Gate**:
- ✅ Can write to EPP sysfs without sudo
- ✅ Changes persist across CPU core iteration

**Rollback**: `sudo rm /etc/udev/rules.d/99-cpu-epp.rules && sudo udevadm control --reload`

---

## Phase 2: Power Management Scripts

**Goal**: Replace ASUS asusctl scripts with Intel EPP-based power management

**Dependencies**: Phase 1 (udev rule installed)

**Tasks**:

### Task 2.1: Create T2 Power Script Directory

```bash
mkdir -p dotfiles/hypr/scripts/t2-power
```

### Task 2.2: Implement cycle-power-mode.sh

**File**: `dotfiles/hypr/scripts/t2-power/cycle-power-mode.sh`

**Implementation**:
```bash
#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
#  Cycles Intel EPP power profiles (REACTOR SLEEP → STABILIZATION → RAZGON).
#  Uses native Intel P-State energy_performance_preference sysfs interface.
#  Bound to XF86Launch4 (F5) in Hyprland config.
# ─────────────────────────────────────────────────────────────────────────────

set -e

# EPP sysfs path
EPP_PATH="/sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference"
LOCK_FILE="/run/user/$UID/power-mode.lock"

# Acquire lock (prevent concurrent execution)
exec 200>"$LOCK_FILE"
flock -n 200 || { echo "Power mode change already in progress"; exit 0; }

# Check if EPP is available
if [[ ! -f "$EPP_PATH" ]]; then
    echo "ERROR: Intel EPP not available. Check CPU supports P-State driver."
    exit 1
fi

# Read current EPP
CURRENT=$(cat "$EPP_PATH")

# Determine next profile
case "$CURRENT" in
    power)
        NEXT="balance_performance"
        ;;
    balance_performance)
        NEXT="performance"
        ;;
    performance)
        NEXT="power"
        ;;
    *)
        # Unknown or default - start cycle
        NEXT="power"
        ;;
esac

# Write new EPP to all CPU cores
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference; do
    echo "$NEXT" > "$cpu" 2>/dev/null || {
        echo "ERROR: Cannot write to EPP. Run: sudo cp dotfiles/system/99-cpu-epp.rules /etc/udev/rules.d/ && sudo udevadm control --reload"
        exit 1
    }
done

# Signal Waybar to update widget (event-driven)
pkill -USR1 waybar 2>/dev/null || true

# Release lock (automatic on script exit)
```

**Make executable**:
```bash
chmod +x dotfiles/hypr/scripts/t2-power/cycle-power-mode.sh
```

### Task 2.3: Test cycle-power-mode.sh

```bash
# Test script execution
./dotfiles/hypr/scripts/t2-power/cycle-power-mode.sh

# Verify EPP changed
cat /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference
# Should show new value (balance_performance or performance or power)

# Test full cycle
./dotfiles/hypr/scripts/t2-power/cycle-power-mode.sh  # Should cycle
./dotfiles/hypr/scripts/t2-power/cycle-power-mode.sh  # Should cycle again
./dotfiles/hypr/scripts/t2-power/cycle-power-mode.sh  # Should wrap to start

# Test concurrent execution (should be safe)
./dotfiles/hypr/scripts/t2-power/cycle-power-mode.sh & ./dotfiles/hypr/scripts/t2-power/cycle-power-mode.sh
# Should see "Power mode change already in progress" from one
```

**Validation Gate**:
- ✅ Script cycles through all 3 EPP modes correctly
- ✅ Concurrent execution is safe (flock works)
- ✅ Error message shown if udev rule missing

---

## Phase 3: Waybar Widget

**Goal**: Display current EPP with nuclear theme in Waybar

**Dependencies**: Phase 2 (cycle-power-mode.sh working)

**Tasks**:

### Task 3.1: Implement power-profile.sh

**File**: `dotfiles/waybar/scripts/power-profile.sh`

**Implementation**:
```bash
#!/bin/bash
# ── power-profile.sh ───────────────────────────────────────
# Description: Display current Intel EPP power profile with color
# Usage: Called by Waybar `custom/power-profile`
# Dependencies: sysfs Intel EPP interface
# ──────────────────────────────────────────────────────────

EPP_PATH="/sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference"

# Read current EPP (graceful fallback if not available)
if [[ -f "$EPP_PATH" ]]; then
    profile=$(cat "$EPP_PATH" 2>/dev/null)
else
    profile="unknown"
fi

# Map EPP to nuclear theme output
case "$profile" in
  performance)
    text="RAZGON"
    fg="#bf616a"
    ;;
  balance_performance)
    text="STABILIZATION"
    fg="#fab387"
    ;;
  power)
    text="REACTOR SLEEP"
    fg="#56b6c2"
    ;;
  *)
    text="EPP ??"
    fg="#ffffff"
    ;;
esac

# Output Pango markup for Waybar
echo "<span foreground='$fg'>$text</span>"
```

**Make executable**:
```bash
chmod +x dotfiles/waybar/scripts/power-profile.sh
```

### Task 3.2: Update Waybar Configuration

**File**: `dotfiles/waybar/config`

**Find and replace** (lines ~81-88):

```json
// OLD (ASUS):
"custom/asus-profile": {
  "exec": "~/.config/waybar/scripts/asus-profile.sh",
  "return-type": "",
  "format": "⚡ {}",
  "interval": 1,
  "tooltip-format": "Toggle ASUS profile",
  "on-click": "/home/pewds/.config/cycle-profile.sh"
}

// NEW (T2 MacBook):
"custom/power-profile": {
  "exec": "~/.config/waybar/scripts/power-profile.sh",
  "return-type": "",
  "format": "⚡ {}",
  "interval": "once",
  "signal": 1,
  "tooltip-format": "Click to cycle power profile",
  "on-click": "~/.config/hypr/scripts/t2-power/cycle-power-mode.sh"
}
```

**Also update module list** (line ~28):
```json
// Change:
"modules-right": [..., "custom/asus-profile", ...]
// To:
"modules-right": [..., "custom/power-profile", ...]
```

### Task 3.3: Update Waybar CSS

**File**: `dotfiles/waybar/style.css`

**Find and replace**:

```css
/* Line 72: Update widget selector */
#custom-power-profile,  /* was: #custom-asus-profile */

/* Line 127: Update widget class name */
#custom-power-profile {  /* was: #custom-asus-profile */
  /* keep all existing styles */
}
```

### Task 3.4: Restart Waybar and Test Widget

```bash
# Restart Waybar to pick up new config
killall waybar
waybar &

# Verify widget shows current EPP
# Should display "REACTOR SLEEP" or "STABILIZATION" or "RAZGON" with themed color

# Test widget click
# Click widget in status bar, verify profile cycles

# Test event-driven update
./dotfiles/hypr/scripts/t2-power/cycle-power-mode.sh
# Widget should update within 1 second (no manual refresh needed)
```

**Validation Gate**:
- ✅ Waybar displays correct EPP mode with themed colors
- ✅ Widget updates immediately after profile change (USR1 signal working)
- ✅ Clicking widget cycles power profile
- ✅ No polling (interval: "once", signal-driven only)

---

## Phase 4: Keyboard Backlight Scripts

**Goal**: Implement MacBook keyboard backlight control and breathing effect

**Dependencies**: None (standalone)

**Tasks**:

### Task 4.1: Create T2 Keyboard Script Directory

```bash
mkdir -p dotfiles/hypr/scripts/t2-kbd
```

### Task 4.2: Implement kbd-breathing.sh

**File**: `dotfiles/hypr/scripts/t2-kbd/kbd-breathing.sh`

**Implementation**:
```bash
#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
#  Toggles MacBook keyboard backlight "breathing" effect.
#  Bound to XF86Launch3 (F4) in Hyprland config.
#  Uses apple::kbd_backlight sysfs device.
# ─────────────────────────────────────────────────────────────────────────────

KEY_BRIGHTNESS_PATH="/sys/class/leds/apple::kbd_backlight/brightness"
MAX_BRIGHTNESS=512
MIN_BRIGHTNESS=1
SLEEP_TIME=0.2
PID_FILE="/tmp/kbd-breathing.pid"

# Check if keyboard backlight exists
if [[ ! -f "$KEY_BRIGHTNESS_PATH" ]]; then
    echo "ERROR: MacBook keyboard backlight not found at $KEY_BRIGHTNESS_PATH"
    exit 1
fi

# If script already running, stop it (toggle off)
if [[ -f "$PID_FILE" ]]; then
    PID=$(cat "$PID_FILE")
    kill "$PID" 2>/dev/null
    rm "$PID_FILE"
    # Restore normal brightness
    echo 128 > "$KEY_BRIGHTNESS_PATH"
    exit 0
fi

# Store current PID
echo $$ > "$PID_FILE"

# Cleanup on exit
trap 'rm -f "$PID_FILE"; echo 128 > "$KEY_BRIGHTNESS_PATH"' EXIT INT TERM

# Breathing loop
while true; do
    # Fade in
    for level in $(seq $MIN_BRIGHTNESS $MAX_BRIGHTNESS); do
        echo "$level" > "$KEY_BRIGHTNESS_PATH" 2>/dev/null || exit 1
        sleep "$SLEEP_TIME"
    done

    # Fade out
    for level in $(seq $MAX_BRIGHTNESS -1 $MIN_BRIGHTNESS); do
        echo "$level" > "$KEY_BRIGHTNESS_PATH" 2>/dev/null || exit 1
        sleep "$SLEEP_TIME"
    done
done
```

**Make executable**:
```bash
chmod +x dotfiles/hypr/scripts/t2-kbd/kbd-breathing.sh
```

### Task 4.3: Test kbd-breathing.sh

```bash
# Start breathing effect
./dotfiles/hypr/scripts/t2-kbd/kbd-breathing.sh

# Observe: keyboard backlight should smoothly fade in/out
# Let it run for ~10 seconds to verify smooth animation

# Stop breathing effect (run script again)
./dotfiles/hypr/scripts/t2-kbd/kbd-breathing.sh

# Verify: brightness restored to 128, animation stopped
```

**Validation Gate**:
- ✅ Breathing effect produces smooth fade in/out animation
- ✅ Toggling script on/off works correctly
- ✅ Brightness restored on exit
- ✅ No errors or flicker

---

## Phase 5: Hyprland Keybindings

**Goal**: Update Hyprland keybindings to use new T2-native scripts

**Dependencies**: Phases 2, 3, 4 (all scripts working)

**Tasks**:

### Task 5.1: Update Hyprland Keybindings

**File**: `dotfiles/hypr/hyprland.conf`

**Find lines 259-262** (ASUS keybindings):
```conf
bind = , XF86KbdBrightnessUp,   exec, ~/.config/hypr/scripts/asus-kbd/kbd-brightness.sh up
bind = , XF86KbdBrightnessDown, exec, ~/.config/hypr/scripts/asus-kbd/kbd-brightness.sh down
bind = , XF86Launch3,           exec, ~/.config/hypr/scripts/asus-kbd/kbd-breathing.sh
bind = , XF86Launch4,           exec, ~/.config/hypr/scripts/asus-kbd/cycle-profile.sh
```

**Replace with T2 MacBook keybindings**:
```conf
bind = , XF86KbdBrightnessUp,   exec, brightnessctl --device='apple::kbd_backlight' set 5%+
bind = , XF86KbdBrightnessDown, exec, brightnessctl --device='apple::kbd_backlight' set 5%-
bind = , XF86Launch3,           exec, ~/.config/hypr/scripts/t2-kbd/kbd-breathing.sh
bind = , XF86Launch4,           exec, ~/.config/hypr/scripts/t2-power/cycle-power-mode.sh
```

**Remove duplicate bindings** (lines ~204, 206 if present):
```conf
# DELETE these if they exist:
bind = , XF86Launch3,           exec, ~/.config/kbd-breathing.sh
bind = , XF86Launch4, exec, ~/.config/hypr/scripts/asus-kbd/cycle-profile.s  # Note typo .s
```

### Task 5.2: Reload Hyprland Config

```bash
# Reload Hyprland to pick up new keybindings
hyprctl reload
```

### Task 5.3: Test All Keybindings

**Manual Testing**:
1. Press **F3** (XF86KbdBrightnessDown) repeatedly → brightness should decrease smoothly
2. Press **F4 keys above F3** (XF86KbdBrightnessUp) repeatedly → brightness should increase smoothly
3. Press **F4** (XF86Launch3) → breathing effect should start
4. Press **F4** again → breathing effect should stop
5. Press **F5** (XF86Launch4) → power profile should cycle
6. Press **F5** two more times → verify full cycle (3 modes), wraps to start
7. Check Waybar widget updates after each F5 press

**Validation Gate**:
- ✅ All keybindings respond correctly
- ✅ No console errors when pressing keys
- ✅ Waybar widget updates reflect power profile changes
- ✅ Keyboard backlight controls work smoothly

---

## Phase 6: Cleanup & Documentation

**Goal**: Remove ASUS artifacts, update documentation

**Dependencies**: Phase 5 (all features working)

**Tasks**:

### Task 6.1: Delete Old ASUS Scripts

```bash
# Remove entire ASUS keyboard directory
rm -rf dotfiles/hypr/scripts/asus-kbd/

# Remove old Waybar ASUS profile script
rm dotfiles/waybar/scripts/asus-profile.sh

# Verify directory structure
tree dotfiles/hypr/scripts/
# Expected:
# dotfiles/hypr/scripts/
# ├── t2-kbd/
# │   └── kbd-breathing.sh
# ├── t2-power/
# │   └── cycle-power-mode.sh
# ├── refresh-eww.sh
# └── waybar_watcher.sh
```

### Task 6.2: Verify Zero ASUS References

```bash
# Search for any remaining ASUS references
grep -r "asus" dotfiles/hypr/ dotfiles/waybar/
grep -r "asusctl" dotfiles/hypr/ dotfiles/waybar/

# Expected: Zero results (or only comments/documentation)
```

### Task 6.3: Update README Documentation

**File**: `dotfiles/hypr/README.md` (if exists)

Add section:
```markdown
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
- linux-t2 kernel (6.11+recommended)
- brightnessctl for keyboard backlight
- Udev rule for EPP permissions (see dotfiles/system/99-cpu-epp.rules)

### Installation
1. Deploy dotfiles: `./deploy.sh`
2. Install udev rule: `sudo cp dotfiles/system/99-cpu-epp.rules /etc/udev/rules.d/ && sudo udevadm control --reload`
3. Reload Hyprland: `hyprctl reload`
```

### Task 6.4: Update DEPLOY.md

**File**: `DEPLOY.md`

Update to reflect T2 hardware:
```markdown
## MacBook Pro 2018 T2 Edition

**Note:** This configuration is now optimized for MacBook Pro T2 hardware. If you're running on different hardware (ASUS ROG, etc.), power management and keyboard controls may need adjustment.

### T2-Specific Setup

After running `./deploy.sh`, install the udev rule for passwordless power management:

\`\`\`bash
sudo cp dotfiles/system/99-cpu-epp.rules /etc/udev/rules.d/
sudo udevadm control --reload
sudo udevadm trigger
\`\`\`

### Hardware Controls

- **F3/F4**: Keyboard backlight brightness
- **F4 (XF86Launch3)**: Keyboard breathing effect
- **F5**: Cycle power profiles (REACTOR SLEEP / STABILIZATION / RAZGON)
```

**Validation Gate**:
- ✅ Zero ASUS references in codebase
- ✅ Documentation updated for T2 hardware
- ✅ README clearly explains T2-specific features

---

## Phase 7: Final Validation & Git Commit

**Goal**: Comprehensive testing and version control

**Dependencies**: All previous phases complete

**Tasks**:

### Task 7.1: Full System Test

**Boot-to-Working Test**:
1. Reboot system
2. Log into Hyprland session
3. Check console for any errors (should be zero)
4. Verify Waybar widget displays current EPP mode
5. Test all keybindings (F3/F4/F5)
6. Verify no ASUS-related errors in logs

**Stress Test**:
1. Rapidly press F5 10 times → should cycle smoothly, no race conditions
2. Toggle breathing effect on/off 5 times → should be responsive
3. Adjust keyboard brightness from 0 to max and back → smooth control
4. Click Waybar widget → should cycle profile
5. Leave system idle for 5 minutes → verify no CPU drain from scripts

**Validation Checklist**:
```
[ ] Boot with zero console errors
[ ] Waybar displays correct power profile
[ ] F3 decreases keyboard brightness smoothly
[ ] F4 increases keyboard brightness smoothly
[ ] F4 (XF86Launch3) toggles breathing effect
[ ] F5 cycles power profiles (all 3 modes)
[ ] Waybar widget updates immediately after profile change
[ ] Clicking widget cycles profile
[ ] Zero ASUS references in grep search
[ ] No background polling (ps aux shows no continuous scripts)
[ ] udev rule enables passwordless EPP writes
```

### Task 7.2: Git Commit

```bash
# Stage all changes
git add dotfiles/hypr/hyprland.conf
git add dotfiles/hypr/scripts/t2-power/
git add dotfiles/hypr/scripts/t2-kbd/
git add dotfiles/waybar/config
git add dotfiles/waybar/scripts/power-profile.sh
git add dotfiles/waybar/style.css
git add dotfiles/system/
git add DEPLOY.md
git add dotfiles/hypr/README.md

# Commit with comprehensive message
git commit -m "$(cat <<'EOF'
Migrate dotfiles from ASUS ROG to MacBook Pro T2 native configuration

Major changes:
- Replace asusctl with Intel EPP for power management
- Implement T2-native keyboard backlight control
- Event-driven Waybar updates (zero polling)
- Nuclear theme preserved (REACTOR SLEEP/STABILIZATION/RAZGON)

New features:
- cycle-power-mode.sh: Intel EPP-based power profile cycling
- power-profile.sh: Waybar widget for EPP display
- kbd-breathing.sh: MacBook keyboard backlight breathing effect
- 99-cpu-epp.rules: Udev rule for passwordless EPP access

Removed:
- All ASUS-specific scripts (asus-kbd directory)
- asusctl dependencies
- Polling-based Waybar updates

Hardware requirements:
- MacBook Pro 2018 T2 with linux-t2 kernel
- Intel CPU with P-State EPP support
- apple::kbd_backlight device
- brightnessctl installed

🍸 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

### Task 7.3: Create Pull Request (Optional)

If using git workflow with branches:
```bash
git push -u origin feature/t2-macbook-migration

# Create PR via gh CLI
gh pr create --title "MacBook T2 Migration: ASUS → T2 Native Configuration" \
  --body "$(cat <<'EOF'
## Summary
Migrates Balder dotfiles from ASUS ROG Zephyrus G15 to MacBook Pro 2018 T2-native configuration.

## Key Changes
- ✅ Intel EPP power management (replaces asusctl)
- ✅ apple::kbd_backlight keyboard control (replaces ASUS sysfs)
- ✅ Event-driven Waybar updates (eliminates polling)
- ✅ Nuclear theme preserved
- ✅ Zero new dependencies

## Test Plan
- [x] All keybindings functional (F3/F4/F5)
- [x] Waybar widget displays correct EPP
- [x] Keyboard backlight controls work
- [x] Breathing effect smooth
- [x] Power profile cycling works
- [x] Zero ASUS references remaining
- [x] Zero console errors on boot
- [x] Udev rule enables passwordless access

## Breaking Changes
- Requires udev rule installation (one-time sudo)
- Only works on Intel CPUs with P-State EPP
- Only works on T2 MacBooks (or compatible hardware)

## Migration Guide
See updated DEPLOY.md for T2-specific setup instructions.

🍸 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

**Validation Gate**:
- ✅ All tests passing
- ✅ Git commit created with comprehensive message
- ✅ Branch pushed to remote (if applicable)
- ✅ PR created (if applicable)

---

## Rollback Plan

If issues arise during implementation:

### Immediate Rollback (Per Phase)
```bash
# Return to previous phase
git reset --hard HEAD~1  # Undo last commit
hyprctl reload          # Reload Hyprland config
killall waybar && waybar &  # Restart Waybar
```

### Full Rollback (Nuclear Option)
```bash
# Return to main branch
git checkout dionysus
git branch -D feature/t2-macbook-migration

# Restore previous config
./deploy.sh
hyprctl reload
killall waybar && waybar &

# Remove udev rule
sudo rm /etc/udev/rules.d/99-cpu-epp.rules
sudo udevadm control --reload
```

---

## Post-Implementation

### Optional Enhancements (Future Work)

**Battery Optimization** (from PRD "Should Have" features):
1. Hyprland VFR: Add `misc { vfr = true }` to hyprland.conf
2. Disable shadows on battery: Create AC/battery mode toggle script
3. Simplify animations: Reduce animation complexity from 19 to ~5 definitions

**HiDPI Optimization** (from PRD "Could Have" features):
1. Test integer scaling (2.0) vs fractional (1.25) for battery impact
2. Configure XWayland app scaling
3. Add GTK/QT scaling environment variables

**T2 Hardware Documentation**:
1. Create `docs/T2_HARDWARE.md` with full hardware support matrix
2. Document what works vs. doesn't work
3. Link to t2linux project resources

---

## Success Metrics

**At Completion**:
- ✅ 100% hardware controls functional (all keybindings work)
- ✅ 0 ASUS references in codebase
- ✅ 0 console errors on boot or usage
- ✅ Event-driven architecture (zero polling scripts)
- ✅ Nuclear theme preserved (visual continuity)
- ✅ < 2-3 hours total implementation time
- ✅ Git history shows clean, logical progression

**User Experience**:
- Configuration feels "native" to MacBook T2
- Power profile switching is instant and intuitive
- Keyboard controls are smooth and responsive
- Waybar widget updates are immediate (no lag)
- System logs are clean (no errors or warnings)

**Code Quality**:
- Scripts are simple and readable (< 50 lines each)
- Error messages are actionable and helpful
- No over-engineering (simple solutions)
- Follows existing dotfiles patterns
- Comprehensive inline documentation

---

## Appendix: Command Reference

### Useful Commands During Implementation

**Check EPP Status**:
```bash
# View current EPP
cat /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference

# View all CPU EPP values
grep . /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference

# Available EPP values
cat /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_available_preferences
```

**Check Keyboard Backlight**:
```bash
# Current brightness
cat /sys/class/leds/apple::kbd_backlight/brightness

# Max brightness
cat /sys/class/leds/apple::kbd_backlight/max_brightness

# Set brightness directly
echo 256 > /sys/class/leds/apple::kbd_backlight/brightness
```

**Waybar Debugging**:
```bash
# Restart Waybar with verbose logging
killall waybar
waybar -l debug &

# Send signal manually
pkill -USR1 waybar

# Check Waybar process
ps aux | grep waybar
```

**Hyprland Debugging**:
```bash
# Reload config
hyprctl reload

# List all keybindings
hyprctl binds

# Check for errors
journalctl --user -u hyprland -n 50
```

---

## Implementation Timeline

**Estimated: 2-3 hours**

- Phase 1 (Udev Rule): 15 minutes
- Phase 2 (Power Scripts): 30 minutes
- Phase 3 (Waybar Widget): 30 minutes
- Phase 4 (Keyboard Scripts): 20 minutes
- Phase 5 (Hyprland Keybindings): 15 minutes
- Phase 6 (Cleanup & Docs): 20 minutes
- Phase 7 (Final Validation): 20 minutes
- **Buffer**: 30 minutes for unexpected issues

**Total**: 2h 30min baseline + 30min buffer = **3 hours maximum**

---

**Ready to execute!** Run `/start:implement 001` to begin implementation.
