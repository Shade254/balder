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
A unified, visually striking fan and power dashboard for T2 MacBook Pro that replaces three broken widgets with one cohesive, functional display showing real-time cooling status and energy metrics.

### Problem Statement
The current EWW dashboard has three power/cooling widgets (`power_mode_text.yuck`, `power_cooling_header_text.yuck`, `right_fan_data.yuck`) that are:

1. **Non-functional**: They reference AMD-specific sensors (`vddgfx`, `vddnb`, `power1:`) that don't exist on Intel T2 MacBook Pro
2. **Broken**: Missing `show_eww` variable causes visibility errors
3. **Poorly styled**: Inconsistent Cyrillic labels, tiny windows, fragmented layout
4. **Hard to maintain**: Three separate windows with overlapping responsibilities

**Evidence**: Running the voltage scripts returns empty values; sensor analysis confirmed AMD sensors are absent.

### Value Proposition
A single, well-designed dashboard that:
- Actually works on T2 Mac hardware
- Provides at-a-glance cooling and power status
- Uses visually appealing large ASCII fan animations
- Follows the codebase's consolidation pattern (fewer, better windows)
- Displays meaningful metrics (power draw, battery energy) instead of unavailable voltages

## User Personas

### Primary Persona: Power User Developer
- **Demographics:** Developer using T2 MacBook Pro as daily driver, technical expertise high
- **Goals:** Monitor system health at a glance while coding, know when system is under load, track battery drain during mobile work
- **Pain Points:** Current widgets show nothing useful, can't tell if fans are spinning or system is thermal throttling, no visibility into power consumption

## User Journey Maps

### Primary User Journey: Monitoring System During Work Session
1. **Awareness:** Laptop feels warm or fans audibly spin up
2. **Consideration:** Glance at dashboard to see fan RPM and power draw
3. **Adoption:** Dashboard is always visible on desktop background
4. **Usage:**
   - See spinning ASCII fans confirm cooling is active
   - Read RPM values to know intensity (1200 = idle, 6000 = max)
   - Check power draw to understand if heavy load or charger issue
   - See battery energy to estimate remaining work time
5. **Retention:** Dashboard becomes essential part of workflow, always visible

## Feature Requirements

### Must Have Features

#### Feature 1: Dual ASCII Fan Display
- **User Story:** As a power user, I want to see animated ASCII representations of both fans so that I can visually confirm cooling is active at a glance
- **Acceptance Criteria:**
  - [ ] Left fan (CPU/fan1) displays animated ASCII spinner
  - [ ] Right fan (GPU/fan2) displays animated ASCII spinner
  - [ ] Spinners animate when RPM > 0
  - [ ] Spinners show static "|" when RPM = 0
  - [ ] ASCII art is large and visually prominent (not tiny text)

#### Feature 2: RPM Display with Cyrillic Units
- **User Story:** As a power user, I want to see fan RPM values with Cyrillic units so that I know how hard the fans are working
- **Acceptance Criteria:**
  - [ ] Left fan RPM displayed below left spinner
  - [ ] Right fan RPM displayed below right spinner
  - [ ] Units shown as "об/мин" (Russian for RPM)
  - [ ] Values update every 5 seconds
  - [ ] Format: "1248 об/мин"

#### Feature 3: Power Draw Indicator
- **User Story:** As a power user, I want to see current power consumption so that I know if system is under heavy load or draining battery fast
- **Acceptance Criteria:**
  - [ ] Power draw displayed in watts (e.g., "25.2W")
  - [ ] Arrow indicates direction: ↑ for charging, ↓ for discharging
  - [ ] Color indicates state: green for charging, orange for discharging
  - [ ] Updates every 5 seconds
  - [ ] Handles edge cases: shows "0.0W" when fully charged

#### Feature 4: Battery Energy Display
- **User Story:** As a power user, I want to see remaining battery energy in watt-hours so that I can estimate remaining work time
- **Acceptance Criteria:**
  - [ ] Battery energy displayed in Wh (e.g., "34.4 Вт·ч")
  - [ ] Full Cyrillic label: "энергия: 34.4 Вт·ч"
  - [ ] Updates every 10 seconds
  - [ ] Accurate to one decimal place

#### Feature X: Power Label
- **User Story:** As a power user, I want clear labels on my metrics
- **Acceptance Criteria:**
  - [ ] Power draw has full Cyrillic label: "мощность: 25.2W↑"
  - [ ] Labels use consistent font/color with existing dashboard

### Should Have Features

#### Feature 5: Large ASCII Fan Art
- **User Story:** As a user who values aesthetics, I want the fans to be visually impressive ASCII art so that the dashboard looks professional
- **Acceptance Criteria:**
  - [ ] Fan ASCII art is 3-5 lines tall (compact but visible)
  - [ ] Fan blades visually rotate through animation frames
  - [ ] Art style matches overall dashboard aesthetic
  - [ ] Widget is borderless (no ASCII box frame)
  - [ ] Layout: Left fan | Metrics | Right fan (horizontal arrangement)

### Could Have Features

#### Feature 6: Fan Speed Percentage
- **User Story:** As a power user, I want to see fan speed as percentage of max so that I can quickly gauge thermal headroom
- **Acceptance Criteria:**
  - [ ] Calculate percentage: current_rpm / max_rpm * 100
  - [ ] Display alongside or instead of raw RPM
  - [ ] Format: "50%" or "1248 об/мин (50%)"

### Won't Have (This Phase)

- **GPU/CPU voltage displays** - Not available on T2 Mac hardware
- **DC input voltage** - Not relevant without AMD power sensors
- **Multiple separate windows** - Consolidating into single window per codebase pattern
- **Temperature displays** - Could be added later, keeping scope focused on fans + power
- **Battery percentage** - Energy in Wh is more precise and useful

## Detailed Feature Specifications

### Feature: Power Draw Indicator (Most Complex)

**Description:** Real-time power consumption display that shows wattage flowing into (charging) or out of (discharging) the battery, with visual indicators for direction and state.

**User Flow:**
1. User glances at dashboard
2. System reads UPower `energy-rate` and `state`
3. Display shows formatted wattage with arrow and color
4. User immediately knows: "Am I charging or draining? How fast?"

**Business Rules:**
- Rule 1: When `state = charging`, show green text with ↑ arrow
- Rule 2: When `state = discharging`, show orange text with ↓ arrow
- Rule 3: When `state = fully-charged`, show neutral color with no arrow, value ~0W
- Rule 4: Always show one decimal place (e.g., "25.2W" not "25W" or "25.248W")

**Edge Cases:**
- Scenario 1: UPower unavailable → Expected: Show "N/A" with neutral styling
- Scenario 2: Rapid state changes (plug/unplug charger) → Expected: Update within 5 seconds
- Scenario 3: energy-rate returns 0 while discharging → Expected: Show "0.0W↓" (system suspended or very low power)

## Success Metrics

### Key Performance Indicators

- **Adoption:** Dashboard displays correctly 100% of the time on T2 Mac
- **Engagement:** All sensor values update at specified intervals without errors
- **Quality:** Zero "N/A" or error states during normal operation
- **Business Impact:** Replaces 3 broken widgets with 1 functional widget

### Tracking Requirements

| Event | Properties | Purpose |
|-------|------------|---------|
| Widget load | timestamp, sensor_availability | Verify all sensors accessible |
| Sensor read failure | sensor_name, error_type | Identify hardware compatibility issues |
| State change | old_state, new_state | Validate charging detection works |

---

## Constraints and Assumptions

### Constraints
- **Hardware:** Must work on T2 MacBook Pro (Intel CPU, Apple T2 chip)
- **Sensors:** Limited to what `lm-sensors` and `upower` expose on T2
- **Platform:** Arch Linux with Hyprland compositor
- **Framework:** EWW widget system (yuck + scss)
- **Visual Consistency:** MUST use existing theme variables from `eww.scss`:
  - `$color-primary` (#9cdef2) for main text/values
  - `$color-secondary` (#56b6c2) for labels
  - `$color-accent` (#61afef) for borders/frames
  - `$color-orange` (#fab387) for highlights/warnings
  - Existing font families (monospace)
  - Existing CSS class patterns (`.stats-label`, `.power-value`, etc.)
- **Cleanup:** Delete old widgets upon completion:
  - `windows/sys/power_mode_text.yuck`
  - `windows/sys/power_cooling_header_text.yuck`
  - `windows/sys/right_fan_data.yuck`

### Assumptions
- `applesmc` kernel module loaded (provides fan sensors)
- `upower` daemon running (provides battery metrics)
- User has existing EWW dashboard infrastructure
- Single monitor setup (monitor 0)

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| UPower output format changes | Medium | Low | Parse defensively, handle missing fields |
| Fan sensors return 0 during sleep | Low | Medium | Show static spinner, don't treat as error |
| ASCII art too large for window | Medium | Medium | Test sizing during design phase |

## Open Questions

- [x] ~~One, two, or three windows?~~ → **Single combined window** (decided)
- [x] ~~Which energy metrics?~~ → **Power draw (W) + Energy (Wh)** (decided)
- [x] ~~How to show charging state?~~ → **Arrow (↑/↓) + color (green/orange)** (decided)

---

## Supporting Research

### Competitive Analysis
Other system monitors (conky, polybar) typically show:
- Fan RPM as plain numbers
- Battery as percentage
- Power as wattage

Our approach differentiates with:
- Large ASCII fan animations (visual appeal)
- Cyrillic labels (unique aesthetic)
- Wh instead of % (more precise for power users)

### User Research
Based on user interview (spec author):
- Wants visual confirmation fans are working
- Prefers precise Wh over vague percentage
- Values aesthetic consistency with existing dashboard
- Frustrated by current broken widgets

### Market Data
N/A - Personal project, not commercial product.
