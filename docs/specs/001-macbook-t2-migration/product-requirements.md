# Product Requirements Document

## Validation Checklist

- [ ] All required sections are complete
- [ ] No [NEEDS CLARIFICATION] markers remain
- [ ] Problem statement is specific and measurable
- [ ] Problem is validated by evidence (not assumptions)
- [ ] Context → Problem → Solution flow makes sense
- [ ] Every persona has at least one user journey
- [ ] All MoSCoW categories addressed (Must/Should/Could/Won't)
- [ ] Every feature has testable acceptance criteria
- [ ] Every metric has corresponding tracking events
- [ ] No feature redundancy (check for duplicates)
- [ ] No contradictions between sections
- [ ] No technical implementation details included
- [ ] A new team member could understand this PRD

---

## Product Overview

### Vision
Transform the ASUS ROG-optimized Balder dotfiles into a MacBook Pro 2018 T2-native configuration that maintains functionality while embracing simplicity, elegance, and hardware-specific optimization.

### Problem Statement
The current Balder dotfiles repository is heavily optimized for ASUS ROG Zephyrus G15 hardware with deep integration of ASUS-specific tools (asusctl) and hardware interfaces (ASUS keyboard backlight sysfs paths). Running this configuration on a MacBook Pro 2018 T2 results in:

**Immediate Pain Points:**
- Non-functional hardware controls (F2-F5 function keys do nothing)
- Failed script execution on every boot (kbd-brightness.sh, cycle-profile.sh)
- Waybar displays "ASUS Profile" widget that shows no data
- Hyprland keybindings trigger errors for ASUS-only commands
- Configuration clutter from unused ASUS scripts (133 lines of dead code)

**Consequences of Not Solving:**
- Degraded user experience (broken features, console errors)
- Inability to control MacBook-specific hardware (keyboard backlight, power profiles)
- Maintenance burden from carrying unused ASUS code
- Confusion for future users or contributors about hardware compatibility
- Missed opportunities to leverage T2 MacBook capabilities

### Value Proposition
This migration delivers a **hardware-native** dotfiles configuration that:

1. **Works immediately** - All hardware controls functional on MacBook Pro T2
2. **Maintains core functionality** - Power profile switching, keyboard backlight control, status bar integration preserved
3. **Embraces simplicity** - Uses native macOS tools (`pmset`) instead of hardware-specific utilities
4. **Follows best practices** - Aligned with Arch Linux superuser patterns (minimal tooling, event-driven updates, battery optimization)
5. **Improves battery life** - Eliminates wasteful polling scripts, optimizes Hyprland animations
6. **Enables future portability** - Clear separation between hardware-specific and generic configurations

## User Personas

### Primary Persona: Linux Power User on MacBook Hardware
- **Demographics:** Advanced Linux user (Arch expertise), developer/sysadmin, 25-40 years old, running Arch Linux on MacBook Pro 2018 T2
- **Goals:**
  - Daily-driver laptop setup with professional aesthetics and reliability
  - Full hardware control (keyboard backlight, power management, display scaling)
  - Battery-optimized workflow for mobile work
  - Minimal, elegant configuration that "just works"
- **Pain Points:**
  - Tired of broken ASUS scripts cluttering the configuration
  - Frustrated by non-functional keybindings (F2-F5 do nothing)
  - Wants native MacBook hardware integration, not workarounds
  - Values simplicity over complexity (anti-over-engineering)
  - Needs configuration that respects battery life on mobile device

## User Journey Maps

### Primary User Journey: MacBook T2 Migration Experience
1. **Awareness:** User clones Balder dotfiles onto MacBook Pro T2, runs setup, immediately sees errors in console about missing asusctl and broken scripts. Function keys (F2-F5) don't work. Waybar shows broken ASUS widget.

2. **Consideration:** User evaluates options:
   - Keep using broken config and live with errors (unacceptable for power user)
   - Manually hack scripts to remove ASUS dependencies (time-consuming, error-prone)
   - Find pre-configured MacBook dotfiles (abandons current customizations)
   - Properly migrate configuration to be hardware-native (ideal but requires effort)

3. **Adoption:** User decides to migrate when they see:
   - Clear specification of what changes are needed
   - Preservation of core functionality (not losing features)
   - Alignment with best practices (not just quick fixes)
   - Estimated effort is reasonable (2-3 hours, not days)

4. **Usage:** After migration:
   - Boots system with zero errors
   - Presses F3/F4 to control keyboard backlight (works immediately)
   - Presses F5 to cycle power profiles (Quiet→Balanced→Performance)
   - Waybar shows current power mode with visual indicator
   - All scripts execute cleanly, no ASUS references remain

5. **Retention:** User maintains config long-term because:
   - It's hardware-native (no compatibility layer)
   - It's simple and understandable (no over-engineering)
   - Battery life is optimized (follows superuser best practices)
   - Easy to adapt for future hardware changes

## Feature Requirements

### Must Have Features

#### Feature 1: Remove All ASUS-Specific Code
- **User Story:** As a MacBook user, I want all ASUS-specific code removed so that my configuration is clean and error-free
- **Acceptance Criteria:**
  - [ ] Delete `dotfiles/hypr/scripts/asus-kbd/kbd-breathing.sh` (not transferable to MacBook)
  - [ ] Delete `dotfiles/hypr/scripts/asus-kbd/kbd-brightness.sh` (replaced by native keys)
  - [ ] Remove F2-F4 keybindings from `hyprland.conf` (lines 217-219)
  - [ ] Remove ASUS references from all documentation files
  - [ ] Zero console errors related to asusctl or ASUS scripts on boot
  - [ ] No dead code paths or unused files remain

#### Feature 2: Power Profile Management for MacBook T2
- **User Story:** As a MacBook user, I want to cycle through power profiles so that I can optimize performance vs battery life
- **Acceptance Criteria:**
  - [ ] New script `cycle-power-mode.sh` uses Intel EPP sysfs interface instead of `asusctl`
  - [ ] Cycles through three modes: REACTOR SLEEP (power) → STABILIZATION (balance_performance) → RAZGON (performance)
  - [ ] F5 key triggers profile cycling
  - [ ] Each profile writes EPP value to all CPU cores via `/sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference`
  - [ ] Visual feedback via event-driven Waybar widget update (no polling)
  - [ ] Udev rule created for passwordless sysfs writes
  - [ ] Script uses flock to prevent concurrent execution

#### Feature 3: Waybar Power Profile Widget
- **User Story:** As a MacBook user, I want to see my current power profile in the status bar so that I know which mode is active
- **Acceptance Criteria:**
  - [ ] New script `power-profile.sh` reads EPP from `/sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference` instead of `asusctl`
  - [ ] Displays themed text: "REACTOR SLEEP" / "STABILIZATION" / "RAZGON" (keeping nuclear theme)
  - [ ] Color-coded: cyan (#56b6c2) for power, orange (#fab387) for balanced, red (#bf616a) for performance
  - [ ] Updates via event-driven signal (USR1) when profile changes, not polling
  - [ ] Clickable to toggle profiles (calls `cycle-power-mode.sh`)
  - [ ] No hardcoded user paths (fix /home/pewds bug in waybar config line 88)

#### Feature 4: Keyboard Backlight Control
- **User Story:** As a MacBook user, I want to control keyboard backlight brightness so that I can work in different lighting conditions
- **Acceptance Criteria:**
  - [ ] XF86KbdBrightnessDown key decreases keyboard backlight brightness
  - [ ] XF86KbdBrightnessUp key increases keyboard backlight brightness
  - [ ] Uses `brightnessctl` with `apple::kbd_backlight` device (verified present on system)
  - [ ] Simple keybindings call `brightnessctl --device='apple::kbd_backlight' set 5%-` and `set 5%+`
  - [ ] Brightness persists within session (kernel manages state)
  - [ ] Graceful handling if keyboard backlight not available (brightnessctl will show error)
  - [ ] Remove old ASUS kbd-brightness.sh script

### Should Have Features

#### Feature 5: Keyboard Backlight Breathing Effect
- **User Story:** As a MacBook user, I want a breathing effect for keyboard backlight so that I have a fun visual customization option
- **Acceptance Criteria:**
  - [ ] XF86Launch3 (F4) toggles breathing effect on/off
  - [ ] New script `kbd-breathing.sh` uses `apple::kbd_backlight` device
  - [ ] Smooth fade in/out animation (MIN 1 → MAX 512 → MIN loop)
  - [ ] PID file prevents multiple instances
  - [ ] Toggling off restores normal brightness level
  - [ ] Minimal battery impact (0.2s sleep between steps)
  - [ ] Remove old ASUS breathing script

#### Feature 6: Hyprland Battery Optimization
- **User Story:** As a mobile MacBook user, I want optimized Hyprland settings so that my battery lasts longer
- **Acceptance Criteria:**
  - [ ] Add `misc { vfr = true }` for variable frame rate (render only when needed)
  - [ ] Disable shadows on battery (`decoration:shadow:enabled = false`)
  - [ ] Disable blur on battery (`decoration:blur:enabled = false`)
  - [ ] Simplified animations (reduce complexity from 19 definitions to ~5)
  - [ ] Documented AC vs battery mode toggle script

#### Feature 7: Fix Existing Configuration Bugs
- **User Story:** As a user, I want all configuration bugs fixed so that the system works correctly
- **Acceptance Criteria:**
  - [ ] Fix typo in line 206 of hyprland.conf (`cycle-profile.s` → `cycle-profile.sh`)
  - [ ] Fix hardcoded path in waybar config line 88 (`/home/pewds/` → correct user/path)
  - [ ] Validate all script paths are correct and relative where appropriate
  - [ ] Test all keybindings actually work

### Could Have Features

#### Feature 8: HiDPI Display Optimization
- **User Story:** As a Retina display user, I want optimized scaling so that text is crisp and readable
- **Acceptance Criteria:**
  - [ ] Test integer scaling (2.0) vs current fractional (1.25) for battery impact
  - [ ] Configure XWayland app scaling properly
  - [ ] Document recommended DPI settings for MacBook Retina
  - [ ] Add environment variables for GTK/QT scaling

#### Feature 9: T2-Specific Hardware Documentation
- **User Story:** As a T2 MacBook user, I want documentation on what hardware features work so that I know the limitations
- **Acceptance Criteria:**
  - [ ] Document what works (keyboard, trackpad, display, WiFi, etc.)
  - [ ] Document what doesn't work (Touch ID, FaceTime camera, hybrid graphics)
  - [ ] Document required kernel (linux-t2) and firmware
  - [ ] Link to t2linux project resources

### Won't Have (This Phase)

**Explicitly Out of Scope:**
- Touch ID support (T2 Secure Enclave incompatible with Linux)
- FaceTime camera support (driver not available)
- Hybrid graphics switching (AMD dGPU issues on 15" models)
- TouchBar advanced customization beyond basic function keys
- Battery charge threshold management (not supported on T2)
- macOS-specific features (Sidecar, Continuity, etc.)
- Complete rewrite of Hyprland config (only ASUS-related changes)
- Migration to different status bar (keeping Waybar)
- Automated hardware detection/config switching (keep it simple)

## Detailed Feature Specifications

### Feature: Power Profile Management for MacBook T2 (Feature 2)
**Description:** Replaces ASUS-specific `asusctl` power profile cycling with native Intel Energy Performance Preference (EPP) interface. Provides three power modes optimized for different usage scenarios (battery conservation, balanced, maximum performance) with seamless integration into Hyprland keybindings and Waybar status display. Uses kernel's native CPU frequency scaling with zero dependencies.

**User Flow:**
1. User presses F5 function key (XF86Launch4)
2. System executes `cycle-power-mode.sh` script
3. Script reads current EPP setting from `/sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference`
4. Script determines next mode in cycle: REACTOR SLEEP (power) → STABILIZATION (balance_performance) → RAZGON (performance) → REACTOR SLEEP
5. Script writes new EPP value to all CPU cores via sysfs
6. Script sends signal to Waybar to update widget (event-driven, no polling)
7. Waybar widget updates to display new mode with themed color coding
8. User sees visual confirmation in status bar

**Business Rules:**
- Rule 1: Profile must cycle in fixed order: REACTOR SLEEP → STABILIZATION → RAZGON → REACTOR SLEEP (wrap around)
- Rule 2: REACTOR SLEEP mode uses EPP "power" setting (maximum battery conservation)
- Rule 3: STABILIZATION mode uses EPP "balance_performance" setting (performance-focused balance)
- Rule 4: RAZGON mode uses EPP "performance" setting (maximum performance, higher power consumption)
- Rule 5: Profile changes take effect immediately via kernel (persist within session, not across reboots by design)
- Rule 6: Script must detect current EPP mode before cycling (not assume state)
- Rule 7: Waybar widget updates immediately via signal (event-driven, not polled)
- Rule 8: Script must handle permissions via udev rule (no sudo prompts during usage)

**Edge Cases:**
- Scenario 1: User presses F5 while profile is being applied → Expected: Use flock on state file to prevent concurrent execution
- Scenario 2: Sysfs write fails (permissions issue) → Expected: Show notification with udev rule setup instructions, log to stderr, exit gracefully
- Scenario 3: Waybar widget shows stale data after profile change → Expected: Script sends USR1 signal to waybar process to force refresh
- Scenario 4: EPP value is manually changed outside script → Expected: Waybar reads actual kernel state, shows real EPP setting (truth from kernel)
- Scenario 5: CPU doesn't support EPP (older Intel) → Expected: Script detects missing sysfs path, shows error, suggests alternatives (TLP/cpupower)

## Success Metrics

### Key Performance Indicators

This is a configuration migration (single-user project), so traditional adoption metrics don't apply. Success is measured by quality and user satisfaction:

- **Quality:** 100% of hardware controls functional (zero console errors, all keybindings work)
- **Code Cleanliness:** 0 ASUS references remaining in codebase
- **Battery Life:** Measurable improvement from Hyprland optimizations (target: 15-20% longer battery life)
- **Implementation Efficiency:** Migration completed within 2-3 hours total effort
- **User Satisfaction:** Configuration feels "native" to MacBook hardware (subjective but critical)

### Tracking Requirements

**Manual Validation Checklist** (no automated analytics needed for single-user config):

| Validation Point | Test Method | Success Criteria |
|------------------|-------------|------------------|
| Boot with zero errors | Start Hyprland, check console | No asusctl errors, no script failures |
| F3 keyboard backlight down | Press F3 key | Keyboard dims smoothly |
| F4 keyboard backlight up | Press F4 key | Keyboard brightens smoothly |
| F5 power profile cycling | Press F5 key 3 times | Cycles through all 3 modes, wraps around |
| Waybar power widget display | Visual inspection | Shows current mode with correct color |
| Waybar widget click | Click widget in status bar | Toggles to next profile |
| Code cleanliness | `grep -r "asus" dotfiles/` | Zero results |
| Battery life | `upower -i /org/freedesktop/UPower/devices/battery_BAT0` | Measure discharge rate before/after |

---

## Constraints and Assumptions

### Constraints

**Technical Constraints:**
- Must run on MacBook Pro 2018 T2 with Arch Linux (linux-t2 kernel required, currently running 6.17.7-arch1-Watanare-T2-1-t2)
- Limited to hardware features supported by T2 Linux drivers (no Touch ID, no FaceTime camera)
- Must use Intel EPP interface (requires Intel CPU with P-State driver, verified present on system)
- Keyboard backlight uses `apple::kbd_backlight` device (max brightness 512, verified present)
- Hyprland and Waybar must remain as the compositor/status bar (no migrations to other tools)
- No additional dependencies allowed beyond what's already installed (brightnessctl confirmed present)

**Time/Resource Constraints:**
- Single-user project (no team coordination needed)
- Target completion: 2-3 hours implementation effort
- No budget for paid tools or services

**Design Constraints:**
- Elegance, simplicity, effectiveness are non-negotiable design goals
- No over-engineering (avoid complex solutions when simple ones suffice)
- Follow Arch Linux superuser best practices (minimal tooling, event-driven, battery-optimized)

### Assumptions

**Hardware Assumptions:**
- User is running MacBook Pro 2018 with T2 chip
- linux-t2 kernel is installed and functional
- WiFi firmware has been extracted from macOS
- Keyboard backlight hardware works (`smc::kbd_backlight` device exists)
- Display backlight works (native macOS function keys functional)

**Software Assumptions:**
- Arch Linux is already installed and configured
- Hyprland compositor is working
- Waybar status bar is installed and running
- `brightnessctl` is available for backlight control (VERIFIED: version installed, apple::kbd_backlight device detected)
- Intel P-State driver active with EPP support (VERIFIED: energy_performance_preference interface available)
- User has sudo privileges for creating udev rules (one-time setup)

**User Assumptions:**
- User is an experienced Arch Linux user (comfortable with dotfiles, shell scripts, configuration)
- User values clean code and best practices over quick hacks
- User understands hardware limitations of T2 MacBooks on Linux
- User is willing to test and validate after migration

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| ~~`pmset` not available on Arch Linux~~ | ~~High~~ | ~~Medium~~ | RESOLVED: Using Intel EPP instead, verified present on system. |
| ~~Keyboard backlight device path different~~ | ~~Medium~~ | ~~Low~~ | RESOLVED: `apple::kbd_backlight` verified present via brightnessctl. |
| Sysfs write permissions not properly configured | High (power profiles require passwordless writes) | Medium | Create comprehensive udev rule. Document setup in SDD. Provide installation script. |
| Breaking existing functionality during migration | High (unusable system) | Low | Create git branch for migration, test each change incrementally, keep rollback option. |
| Battery optimization has negative performance impact | Medium (user dissatisfaction) | Medium | Make optimizations toggleable (AC vs battery profiles), document trade-offs clearly. |
| ~~Waybar widget polling causes CPU drain~~ | ~~Medium~~ | ~~Low~~ | RESOLVED: Using event-driven signal-based updates (USR1), zero polling. |
| User expectations don't match T2 hardware capabilities | Low (documentation issue) | High | Clearly document what works vs doesn't work in T2-specific docs. Set realistic expectations upfront. |
| Over-engineering trap (complex solutions) | Medium (defeats simplicity goal) | Medium | Strict adherence to "simple over complex" principle. Code review against best practices research. |
| Time estimate wrong (takes longer than 2-3 hours) | Low (single-user project) | Medium | Break work into phases. Must-haves first, should-haves optional. Accept incomplete if time runs out. |

## Open Questions

**Critical Questions for User:**
- [x] ~~Is `pmset` actually available?~~ RESOLVED: Using Intel EPP instead, verified available
- [x] ~~Power profile names?~~ RESOLVED: Keeping nuclear theme (REACTOR SLEEP / STABILIZATION / RAZGON)
- [x] ~~Waybar update mechanism?~~ RESOLVED: Event-driven via USR1 signal, no polling
- [x] ~~Keep breathing effect?~~ RESOLVED: Yes, reimplement for apple::kbd_backlight
- [ ] Do you want battery optimizations enabled by default, or toggleable? (Affects Hyprland config design)
- [ ] Do you want notifications when power profile changes, or just Waybar update? (Visual feedback design)

**Technical Questions to Resolve:**
- [x] ~~Keyboard backlight sysfs path?~~ RESOLVED: `apple::kbd_backlight` verified present (max 512)
- [x] ~~Is `brightnessctl` installed?~~ RESOLVED: Yes, working with apple::kbd_backlight device
- [x] ~~CPU frequency scaling support?~~ RESOLVED: Intel P-State with EPP (power/balance_performance/performance)
- [ ] What display scaling are you currently using - does 1.25 work well for you? (Battery vs readability trade-off)
- [ ] Should we create startup service to set default EPP on boot, or leave at kernel default?

**Design Decisions Needed:**
- [x] ~~Waybar theme colors?~~ RESOLVED: Keep existing (cyan #56b6c2 / orange #fab387 / red #bf616a)
- [ ] Animation complexity: Disable completely on battery, or just reduce? (User preference)
- [ ] Should we document T2 limitations in README or separate T2_HARDWARE.md file? (Documentation structure)

---

## Supporting Research

### Competitive Analysis

**How Other Projects Handle MacBook Linux Configurations:**

1. **t2linux Project (Official T2 Support)**
   - Provides working kernel patches and drivers for T2 MacBooks
   - Documentation focuses on getting hardware working, not integration elegance
   - Learning: Hardware support is solved, but user experience optimization is left to users

2. **Popular Hyprland Dotfiles for MacBooks**
   - Most use generic Linux solutions (TLP, brightnessctl) without MacBook-specific optimization
   - Few leverage native macOS tools or T2-specific capabilities
   - Learning: Gap exists for MacBook-native, elegant configurations

3. **ASUS ROG Linux Configurations**
   - Heavy reliance on `asusctl` (manufacturer-specific tool)
   - Well-integrated but not portable to other hardware
   - Learning: Our current config is best-in-class for ASUS but zero-value for MacBook

**Key Insights:**
- No "gold standard" for MacBook Hyprland configurations exists
- Opportunity to create reference implementation for T2 MacBooks
- Simplicity and hardware-native approach differentiates from generic solutions

### User Research

**Research Conducted:** Specialist agent analysis of current codebase + Arch Linux community best practices

**Key Findings:**

1. **Current ASUS Integration Analysis** (133 lines of code):
   - 2 features directly transferable (power profiles, status widget)
   - 1 feature partially transferable (keyboard brightness - simpler on macOS)
   - 1 feature not transferable (breathing effect - hardware limitation)
   - **Insight:** 50% of ASUS functionality can be preserved with adaptation

2. **T2 MacBook Hardware Capabilities Research**:
   - Keyboard backlight: Fully supported via `smc::kbd_backlight`
   - Power management: Native macOS `pmset` available (if running macOS partition) OR Linux alternatives (TLP, cpupower)
   - TouchBar: Basic function key support via `tiny-dfr`
   - **Insight:** Hardware capabilities match or exceed ASUS functionality for our use cases

3. **Arch Superuser Best Practices Research**:
   - Preference for minimal, single-purpose tools over complex solutions
   - Event-driven updates preferred over polling (battery life)
   - Native compositor features preferred over custom scripts
   - **Insight:** Current config has anti-patterns (1-second polling, excessive animations)

### Market Data

**Target Audience:** Single user (configuration owner) running MacBook Pro 2018 T2

**Broader Context:**
- T2 MacBook market (2016-2020 models): Estimated 10,000+ Linux users based on t2linux community size
- Hyprland adoption: Growing rapidly in 2024-2025, becoming popular tiling compositor
- Arch on MacBook trend: Increasing as T2 support matures (kernel 6.11+ improvements)

**Relevance:**
While this is a single-user project, creating a clean MacBook-native reference implementation could benefit the broader t2linux + Hyprland community. Documentation and patterns established here could be shared.
