# Product Requirements Document

## Validation Checklist

- [x] All required sections are complete
- [x] No [NEEDS CLARIFICATION] markers remain
- [x] Problem statement is specific and measurable
- [x] Problem is validated by evidence (not assumptions)
- [x] Context → Problem → Solution flow makes sense
- [x] Every persona has at least one user journey
- [x] All MoSCoW categories addressed (Must/Should/Could/Won't)
- [x] Every feature has testable acceptance criteria
- [x] Every metric has corresponding tracking events
- [x] No feature redundancy (check for duplicates)
- [x] No contradictions between sections
- [x] No technical implementation details included
- [x] A new team member could understand this PRD

---

## Product Overview

### Vision
Bring the rich, cyberpunk-aesthetic system monitoring dashboard from the original Dionysus dotfiles to Balder, providing real-time hardware visibility on MacBook Pro T2 with the same "neon reactor-core" visual identity.

### Problem Statement
The Balder repository currently lacks the comprehensive system monitoring HUD that was a signature feature of Dionysus. Users have no at-a-glance visibility into system performance (CPU, RAM, fans, network) on their T2 MacBook. The original eww configuration was built for ASUS hardware with AMD/NVIDIA components and contains hardcoded sensor names, network interfaces, and GPU commands that fail silently or produce incorrect data on Apple T2 hardware.

**Evidence:**
- `nvidia-smi` commands return errors (no NVIDIA hardware)
- Sensor scripts look for `vddgfx`, `vddnb`, `Tctl` (AMD-specific) - not present on T2
- Network scripts hardcode `wlp4s0` interface - T2 uses `wlan0`
- Cava audio source references non-existent PulseAudio device

### Value Proposition
A properly ported eww dashboard will provide:
- **Real-time system awareness** - CPU temps, fan speeds, memory usage at a glance
- **Network monitoring** - Upload/download speeds, ping latency, VPN status
- **Visual continuity** - Same cyberpunk ASCII aesthetic from Dionysus
- **T2-specific insights** - Apple sensor data (multiple thermal zones, battery stats)

## User Personas

### Primary Persona: Power User (Miro)
- **Demographics:** Developer/sysadmin, highly technical, uses Hyprland daily
- **Goals:**
  - Monitor system health without opening terminal
  - Quick visual check of thermals during heavy workloads
  - Aesthetic desktop that reflects technical identity
- **Pain Points:**
  - No current visibility into T2 hardware sensors
  - Missing the "at-a-glance" dashboard from previous setup
  - Must manually run `sensors` command to check temps

### Secondary Personas
Not applicable - this is a personal dotfiles configuration for single-user use.

## User Journey Maps

### Primary User Journey: Daily Desktop Monitoring
1. **Awareness:** User logs into Hyprland session, dashboard loads automatically
2. **Consideration:** N/A (no alternatives being evaluated - this is the chosen solution)
3. **Adoption:** Dashboard appears on dedicated workspace or screen region
4. **Usage:**
   - Glance at CPU/RAM bars during work
   - Check fan RPMs during compile jobs
   - Verify network connectivity via ping/VPN widgets
   - Enjoy audio visualizer during music playback
5. **Retention:** Dashboard provides continuous value through passive monitoring

### Secondary User Journeys
Not applicable - single usage pattern.

## Feature Requirements

### Must Have Features (Phase 1 - Bare Minimum)

#### Feature 1: Core Widget Framework
- **User Story:** As a user, I want eww to launch and display widgets without errors so that I have a working foundation
- **Acceptance Criteria:**
  - [ ] `eww daemon` starts without errors
  - [ ] `eww open-many` command opens all windows without crashes
  - [ ] Widgets render in correct screen positions
  - [ ] No error spam in journal/logs

#### Feature 2: Basic System Info Display
- **User Story:** As a user, I want to see hostname, uptime, date/time, and weather so that I have basic environmental awareness
- **Acceptance Criteria:**
  - [ ] Welcome text shows username@hostname
  - [ ] Uptime counter increments correctly
  - [ ] Date/time updates every second
  - [ ] Weather fetches from wttr.in (may show N/A if offline)

#### Feature 3: Workspace Indicators
- **User Story:** As a user, I want to see which Hyprland workspace is active so that I know my navigation context
- **Acceptance Criteria:**
  - [ ] Workspace 1-4 indicators display correctly
  - [ ] Active workspace is visually distinguished
  - [ ] Updates within 1 second of workspace change

#### Feature 4: Memory & Storage Bars
- **User Story:** As a user, I want to see RAM and disk usage as visual bars so that I can spot resource constraints
- **Acceptance Criteria:**
  - [ ] RAM bar shows current usage percentage
  - [ ] Storage bar shows root filesystem usage
  - [ ] Bars update at reasonable intervals (5-10 seconds)
  - [ ] Numeric values displayed alongside bars

### Should Have Features (Phase 2 - T2 Sensor Rewiring + Enhancements)

#### Feature 5: CPU Temperature Monitoring
- **User Story:** As a user, I want to see CPU temperature so that I can monitor thermal performance
- **Acceptance Criteria:**
  - [ ] Reads from `coretemp-isa-0000` Package id 0 sensor
  - [ ] Displays temperature in Celsius
  - [ ] Updates every 5 seconds

#### Feature 6: Fan Speed Monitoring
- **User Story:** As a user, I want to see both fan RPMs so that I know cooling status
- **Acceptance Criteria:**
  - [ ] Reads fan1 and fan2 from applesmc
  - [ ] Displays RPM values
  - [ ] ASCII spinner animation reflects fan activity
  - [ ] Shows static indicator when fans at idle

#### Feature 7: Network Interface Monitoring
- **User Story:** As a user, I want to see upload/download speeds so that I can monitor network activity
- **Acceptance Criteria:**
  - [ ] Reads from `wlan0` interface (T2 WiFi)
  - [ ] Shows upload speed as percentage bar
  - [ ] Shows download speed as percentage bar
  - [ ] Updates every 3 seconds

#### Feature 8: Ping Latency Display
- **User Story:** As a user, I want to see network latency so that I know connection quality
- **Acceptance Criteria:**
  - [ ] Pings 1.1.1.1 and displays ms value
  - [ ] Shows 0 or error indicator when offline
  - [ ] Updates every 5 seconds

#### Feature 9: Audio Visualizer
- **User Story:** As a user, I want to see an ASCII audio visualizer so that I have visual feedback during music playback
- **Acceptance Criteria:**
  - [ ] Cava reads from correct PipeWire audio source
  - [ ] Python visualizer script processes cava output
  - [ ] ASCII art displays in eww widget
  - [ ] Shows "standby" when no audio playing

#### Feature 10: Battery Status Widget
- **User Story:** As a user, I want to see battery percentage and time remaining so that I can manage power
- **Acceptance Criteria:**
  - [ ] Shows current battery percentage
  - [ ] Shows time to empty when discharging
  - [ ] Shows charging status when plugged in
  - [ ] Reads from BAT0 upower interface

#### Feature 11: Intel GPU Monitoring
- **User Story:** As a user, I want to see iGPU utilization so that I can monitor graphics workload
- **Acceptance Criteria:**
  - [ ] Uses `intel_gpu_top` or equivalent to read GPU usage
  - [ ] Displays as percentage or bar
  - [ ] Falls back gracefully if tool unavailable

#### Feature 12: PCH Temperature Display
- **User Story:** As a user, I want to see PCH (chipset) temperature alongside CPU so that I have fuller thermal awareness
- **Acceptance Criteria:**
  - [ ] Reads from `pch_cannonlake-virtual-0` temp1 sensor
  - [ ] Displays temperature in Celsius with "PCH" label
  - [ ] Updates every 5 seconds

#### Feature 13: NordVPN Status Widget
- **User Story:** As a user, I want to see my VPN connection status so that I know when I'm protected
- **Acceptance Criteria:**
  - [ ] Reads from `nordvpn status` command
  - [ ] Shows "Connected" with country when VPN active
  - [ ] Shows "Disconnected" when VPN off
  - [ ] Updates every 5-10 seconds

### Could Have Features (Phase 3 - Nice-to-Have Enhancements)

*No features in this category - all T2 enhancements elevated to Should Have*

### Won't Have (This Phase)

- **NVIDIA GPU monitoring** - No NVIDIA hardware on T2
- **AMD voltage sensors** - vddgfx, vddnb not available on Intel/Apple
- **CPU voltage display** - Not exposed by T2 hardware
- **Discrete GPU fan** - T2 has shared cooling, no separate GPU fan
- **strongSwan VPN status** - Will use NordVPN CLI instead if VPN monitoring needed

## Detailed Feature Specifications

### Feature: Fan Speed Monitoring (Phase 2 - Most complex rewiring)

**Description:** Display both MacBook fan RPMs with animated ASCII spinners that reflect activity state.

**User Flow:**
1. User views dashboard
2. System polls applesmc sensors every 5 seconds
3. Fan RPM values update in display
4. ASCII spinner animates at 0.2s intervals when fans > 0 RPM
5. Spinner shows static "|" when fans at idle (0 RPM)

**Business Rules:**
- Rule 1: Fan sensor names are `fan1` and `fan2` in applesmc output
- Rule 2: RPM of 0 means fan is idle, display static spinner
- Rule 3: Any RPM > 0 triggers animation cycle
- Rule 4: Label as "Left Fan" and "Right Fan" for clarity (T2 has dual fans)

**Edge Cases:**
- Scenario 1: applesmc module not loaded → Expected: Display "N/A" for both fans
- Scenario 2: Only one fan detected → Expected: Display available fan, show "N/A" for other
- Scenario 3: Fan RPM exceeds max_fan_rpm variable → Expected: Clamp display, don't overflow

## Success Metrics

### Key Performance Indicators

- **Adoption:** Dashboard loads successfully on every Hyprland session start
- **Engagement:** All widgets update at their defined intervals without stalling
- **Quality:** Zero error messages in eww daemon logs after 1 hour runtime
- **Business Impact:** N/A (personal project, not commercial)

### Tracking Requirements

| Event | Properties | Purpose |
|-------|------------|---------|
| eww_daemon_start | timestamp, success/failure | Verify startup reliability |
| widget_poll_error | widget_name, error_message | Identify failing sensors |
| sensor_read_failure | sensor_name, fallback_used | Track T2 compatibility issues |

---

## Constraints and Assumptions

### Constraints
- **Hardware:** MacBook Pro T2 with Intel Iris Plus 655, no discrete GPU
- **Sensors:** Limited to what applesmc, coretemp, and standard Linux tools expose
- **Dependencies:** Requires eww, cava, lm-sensors, jq, curl, python3, numpy
- **Audio:** Must use PipeWire source names (not PulseAudio device from original)

### Assumptions
- lm-sensors is installed and sensors-detect has been run
- Hyprland is the window manager
- User has network connectivity for weather widget
- eww is installed and in PATH
- applesmc kernel module is loaded (standard on t2linux)

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| applesmc sensor names change in kernel updates | Medium | Low | Abstract sensor names to config variables |
| Audio visualizer fails without cava running | Low | Medium | Show graceful "standby" state |
| Network interface name differs on other T2 Macs | Medium | Low | Document interface name in config |
| eww version incompatibility | High | Low | Pin eww version in documentation |
| Intel GPU tools not available in Arch repos | Medium | Medium | Make Feature 11 optional, document manual install |

## Open Questions

- [x] What network interface does T2 use? → Confirmed: `wlan0`
- [x] What audio source should cava use? → Confirmed: `alsa_output.pci-0000_02_00.3.Speakers.monitor`
- [x] Should we keep dual-fan display or merge into single "Cooling" metric? → **Dual fans (Left/Right)** - Keep separate displays
- [x] Preferred thermal zones to display from applesmc? → **CPU + PCH** - Show CPU temp plus chipset temperature
- [x] Should VPN status widget use NordVPN CLI or be removed? → **Adapt to NordVPN CLI** - Rewire to use `nordvpn status`

---

## Supporting Research

### Competitive Analysis
N/A - This is a port of our own previous configuration, not competing with external products.

### User Research
Based on personal experience with original Dionysus setup:
- ASCII visualizer is high-value for aesthetic appeal
- Fan/temp monitoring most useful during compile/heavy tasks
- Workspace indicators essential for multi-workspace workflow
- Voltage widgets rarely looked at (low priority for port)

### Market Data
N/A - Personal dotfiles project.
