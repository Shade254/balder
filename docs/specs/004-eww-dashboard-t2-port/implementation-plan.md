# Implementation Plan

## Validation Checklist

- [x] All specification file paths are correct and exist
- [x] Context priming section is complete
- [x] All implementation phases are defined
- [x] Each phase follows TDD: Prime → Test → Implement → Validate
- [x] Dependencies between phases are clear (no circular dependencies)
- [x] Parallel work is properly tagged with `[parallel: true]`
- [x] Activity hints provided for specialist selection `[activity: type]`
- [x] Every phase references relevant SDD sections
- [x] Every test references PRD acceptance criteria
- [x] Integration & E2E tests defined in final phase
- [x] Project commands match actual project setup
- [x] A developer could follow this plan independently

---

## Specification Compliance Guidelines

### How to Ensure Specification Adherence

1. **Before Each Phase**: Complete the Pre-Implementation Specification Gate
2. **During Implementation**: Reference specific SDD sections in each task
3. **After Each Task**: Run Specification Compliance checks
4. **Phase Completion**: Verify all specification requirements are met

### Deviation Protocol

If implementation cannot follow specification exactly:
1. Document the deviation and reason
2. Get approval before proceeding
3. Update SDD if the deviation is an improvement
4. Never deviate without documentation

## Metadata Reference

- `[parallel: true]` - Tasks that can run concurrently
- `[component: component-name]` - For multi-component features
- `[ref: document/section; lines: 1, 2-3]` - Links to specifications, patterns, or interfaces and (if applicable) line(s)
- `[activity: type]` - Activity hint for specialist agent selection

---

## Context Priming

*GATE: You MUST fully read all files mentioned in this section before starting any implementation.*

**Specification**:

- `docs/specs/004-eww-dashboard-t2-port/product-requirements.md` - Product Requirements (13 features across 2 phases)
- `docs/specs/004-eww-dashboard-t2-port/solution-design.md` - Solution Design (5 ADRs confirmed)

**Key Design Decisions** (from SDD):

- **ADR-1**: Replace voltage widgets with CPU freq/governor and SSD temperature
- **ADR-2**: Rename fan parameters from cpu/gpu to left/right
- **ADR-3**: Add dedicated Battery widget using upower
- **ADR-4**: Use NordVPN CLI for VPN status
- **ADR-5**: Create unified multi-thermal display (CPU, PCH, SSD)

**Implementation Context**:

- Commands to run:
  ```bash
  # Test sensor scripts
  bash dotfiles/eww/scripts/sys/sys_fan_spin.sh left
  sensors | grep -E "fan[12]:|Package id|pch_cannonlake|nvme"

  # Test eww
  eww daemon
  eww open-many [widgets]
  eww logs

  # Test cava
  cava -p ~/.config/cava/config &
  cat /tmp/cava.raw
  ```

- Patterns to follow: `[ref: SDD/Section "Implementation Patterns"]`
- Interfaces to implement: `[ref: SDD/Section "Interface Specifications"]`

---

## Implementation Phases

### Phase 1: Core Foundation (Bare Minimum)

*Goal: Get eww launching without errors, basic widgets rendering*

- [x] **T1 Phase 1: Core Foundation** `[ref: PRD/Features 1-4]`

    - [x] T1.1 Prime Context
        - [x] T1.1.1 Read eww.yuck main config `[ref: dotfiles/eww/eww.yuck]` `[activity: read-code]`
        - [x] T1.1.2 Read waybar_watcher.sh integration `[ref: dotfiles/hypr/scripts/waybar_watcher.sh]` `[activity: read-code]`
        - [x] T1.1.3 Verify eww is installed: `command -v eww` `[activity: verify-deps]`
        - [x] T1.1.4 Verify lm-sensors configured: `sensors` shows applesmc data `[activity: verify-deps]`

    - [x] T1.2 Test Existing Functionality
        - [x] T1.2.1 Test eww daemon starts: `eww daemon` runs without error `[activity: manual-test]`
        - [x] T1.2.2 Identify failing defpoll commands by checking `eww logs` `[activity: diagnose]`
        - [x] T1.2.3 Document all nvidia-smi and AMD sensor errors `[activity: diagnose]`

    - [x] T1.3 Implement Core Fixes
        - [x] T1.3.1 Comment out or remove nvidia-smi defpoll variables in eww.yuck `[ref: SDD/ADR-1]` `[activity: edit-config]`
        - [x] T1.3.2 Comment out AMD voltage defpoll variables (vddgfx, vddnb, Tctl) `[ref: SDD/ADR-1]` `[activity: edit-config]`
        - [x] T1.3.3 Update CPU temp defpoll to use coretemp: `sensors | grep 'Package id 0:' | awk '{print $4}'` `[activity: edit-config]`

    - [x] T1.4 Validate Phase 1
        - [x] T1.4.1 `eww daemon` starts without errors `[activity: run-tests]`
        - [x] T1.4.2 `eww open-many` opens widgets without crashes `[activity: run-tests]`
        - [x] T1.4.3 Basic system info displays (hostname, uptime, date) `[ref: PRD/Feature 2]` `[activity: manual-test]`
        - [x] T1.4.4 Workspace indicators work `[ref: PRD/Feature 3]` `[activity: manual-test]`
        - [x] T1.4.5 RAM/Storage bars display correctly `[ref: PRD/Feature 4]` `[activity: manual-test]`

---

### Phase 2: T2 Sensor Rewiring

*Goal: All sensor scripts reading from correct T2 hardware*

- [x] **T2 Phase 2: T2 Sensor Rewiring** `[ref: PRD/Features 5-9; SDD/ADR-1,2]`

    - [x] T2.1 Network Interface Fix `[parallel: true]` `[component: network]`
        - [x] T2.1.1 Prime: Read net_upload.sh, net_download.sh `[ref: dotfiles/eww/scripts/net/]` `[activity: read-code]`
        - [x] T2.1.2 Test: Verify wlan0 exists: `ip link show wlan0` `[activity: verify-deps]`
        - [x] T2.1.3 Implement: Change `iface="wlp4s0"` to `iface="wlan0"` in net_upload.sh `[activity: edit-script]`
        - [x] T2.1.4 Implement: Change `iface="wlp4s0"` to `iface="wlan0"` in net_download.sh `[activity: edit-script]`
        - [x] T2.1.5 Validate: Run scripts, verify non-zero output during network activity `[activity: manual-test]`

    - [x] T2.2 Fan Sensor Rewiring `[parallel: true]` `[component: sys]`
        - [x] T2.2.1 Prime: Read sys_fan_spin.sh `[ref: dotfiles/eww/scripts/sys/sys_fan_spin.sh]` `[activity: read-code]`
        - [x] T2.2.2 Test: Verify fan sensors: `sensors | grep -E "^fan[12]:"` `[activity: verify-deps]`
        - [x] T2.2.3 Implement: Modify sys_fan_spin.sh to use left/right params with fan1/fan2 sensors `[ref: SDD/ADR-2]` `[activity: edit-script]`
        - [x] T2.2.4 Implement: Update eww.yuck defpoll to call with "left" and "right" params `[activity: edit-config]`
        - [x] T2.2.5 Implement: Update eww.yuck fan RPM defpoll to grep fan1/fan2 `[activity: edit-config]`
        - [x] T2.2.6 Validate: Both fan spinners animate, RPM values display `[ref: PRD/Feature 6]` `[activity: manual-test]`

    - [x] T2.3 VPN Status Rewiring `[parallel: true]` `[component: network]`
        - [x] T2.3.1 Prime: Read net_vpn_status.sh, net_vpn.sh `[ref: dotfiles/eww/scripts/net/]` `[activity: read-code]`
        - [x] T2.3.2 Test: Verify NordVPN CLI: `nordvpn status` `[activity: verify-deps]`
        - [x] T2.3.3 Implement: Rewrite net_vpn_status.sh to parse `nordvpn status` output `[ref: SDD/ADR-4]` `[activity: edit-script]`
        - [x] T2.3.4 Implement: Update net_vpn.sh for bar rendering compatibility `[activity: edit-script]`
        - [x] T2.3.5 Validate: Widget shows Connected/Disconnected correctly `[ref: PRD/Feature 13]` `[activity: manual-test]`

    - [x] T2.4 Audio Visualizer Fix `[parallel: true]` `[component: audio]`
        - [x] T2.4.1 Prime: Read cava config `[ref: dotfiles/cava/config]` `[activity: read-code]`
        - [x] T2.4.2 Test: Get correct audio source: `pactl list short sources | grep monitor` `[activity: verify-deps]`
        - [x] T2.4.3 Implement: Update cava config source to `alsa_output.pci-0000_02_00.3.Speakers.monitor` `[activity: edit-config]`
        - [x] T2.4.4 Implement: Set method to `pipewire` (or keep pulse with PipeWire compat) `[activity: edit-config]`
        - [x] T2.4.5 Validate: Start cava, play audio, verify /tmp/cava.raw updates `[activity: manual-test]`
        - [x] T2.4.6 Validate: Visualizer widget displays animated ASCII `[ref: PRD/Feature 9]` `[activity: manual-test]`

    - [x] T2.5 Validate Phase 2
        - [x] T2.5.1 All network scripts use wlan0 `[activity: review-code]`
        - [x] T2.5.2 Fan spinners animate correctly for both fans `[activity: manual-test]`
        - [x] T2.5.3 VPN status shows correct state `[activity: manual-test]`
        - [x] T2.5.4 Audio visualizer works with music playback `[activity: manual-test]`
        - [x] T2.5.5 No errors in eww logs `[activity: run-tests]`

---

### Phase 3: T2 Enhancements

*Goal: Add T2-specific widgets replacing removed AMD/NVIDIA features*

- [ ] **T3 Phase 3: T2 Enhancements** `[ref: PRD/Features 10-13; SDD/ADR-1,3,5]`

    - [ ] T3.1 Multi-Thermal Display `[parallel: true]` `[component: sys]`
        - [ ] T3.1.1 Prime: Review SDD thermal data models `[ref: SDD/Section "Application Data Models"]` `[activity: read-docs]`
        - [ ] T3.1.2 Create: sys_cpu_temp.sh - Read coretemp Package id 0 `[activity: create-script]`
        - [ ] T3.1.3 Create: sys_pch_temp.sh - Read pch_cannonlake temp1 `[activity: create-script]`
        - [ ] T3.1.4 Create: sys_ssd_temp.sh - Read nvme-pci Composite temp `[activity: create-script]`
        - [ ] T3.1.5 Add defpoll variables in eww.yuck for all three temps `[activity: edit-config]`
        - [ ] T3.1.6 Validate: All three temps display correctly `[ref: PRD/Feature 5,12]` `[activity: manual-test]`

    - [ ] T3.2 CPU Frequency/Governor Widget `[parallel: true]` `[component: sys]`
        - [ ] T3.2.1 Prime: Research CPU freq reading methods `[activity: research]`
        - [ ] T3.2.2 Create: sys_cpu_freq.sh - Read current CPU frequency or scaling governor `[activity: create-script]`
        - [ ] T3.2.3 Add defpoll variable in eww.yuck `[activity: edit-config]`
        - [ ] T3.2.4 Repurpose voltage widget display for CPU freq `[ref: SDD/ADR-1]` `[activity: edit-config]`
        - [ ] T3.2.5 Validate: Frequency/governor displays and updates `[activity: manual-test]`

    - [ ] T3.3 Battery Widget `[parallel: true]` `[component: sys]`
        - [ ] T3.3.1 Prime: Review upower output format `[activity: research]`
        - [ ] T3.3.2 Create: sys_battery.sh - Read BAT0 percentage, status, time remaining `[activity: create-script]`
        - [ ] T3.3.3 Add defpoll variables in eww.yuck for battery data `[activity: edit-config]`
        - [ ] T3.3.4 Create: battery_widget.yuck - New widget layout `[ref: SDD/ADR-3]` `[activity: create-widget]`
        - [ ] T3.3.5 Add battery_widget to waybar_watcher.sh eww_windows list `[activity: edit-script]`
        - [ ] T3.3.6 Validate: Battery percentage, status, and time remaining display `[ref: PRD/Feature 10]` `[activity: manual-test]`

    - [ ] T3.4 Intel GPU Monitoring (Optional) `[parallel: true]` `[component: sys]`
        - [ ] T3.4.1 Prime: Check if intel-gpu-tools installed: `command -v intel_gpu_top` `[activity: verify-deps]`
        - [ ] T3.4.2 If available: Create sys_igpu_usage.sh using intel_gpu_top `[activity: create-script]`
        - [ ] T3.4.3 If not available: Document as optional, show N/A `[activity: document]`
        - [ ] T3.4.4 Add defpoll variable if implemented `[activity: edit-config]`
        - [ ] T3.4.5 Validate: GPU usage displays or gracefully shows N/A `[ref: PRD/Feature 11]` `[activity: manual-test]`

    - [ ] T3.5 Validate Phase 3
        - [ ] T3.5.1 All three thermal readings display (CPU, PCH, SSD) `[activity: manual-test]`
        - [ ] T3.5.2 CPU frequency widget shows valid data `[activity: manual-test]`
        - [ ] T3.5.3 Battery widget shows percentage and status `[activity: manual-test]`
        - [ ] T3.5.4 No errors in eww logs with new widgets `[activity: run-tests]`

---

### Phase 4: Integration & End-to-End Validation

*Goal: Complete system works reliably, all PRD requirements met*

- [ ] **T4 Phase 4: Integration & E2E Validation** `[ref: PRD/Success Metrics; SDD/Quality Requirements]`

    - [ ] T4.1 Full System Test
        - [ ] T4.1.1 Start waybar_watcher.sh `[activity: integration-test]`
        - [ ] T4.1.2 Verify dashboard appears on empty workspace `[activity: integration-test]`
        - [ ] T4.1.3 Verify dashboard hides when window opens `[activity: integration-test]`
        - [ ] T4.1.4 Verify waybar appears when window opens `[activity: integration-test]`
        - [ ] T4.1.5 Cycle through workspaces, verify workspace indicators `[activity: integration-test]`

    - [ ] T4.2 Sensor Reliability Test
        - [ ] T4.2.1 Run dashboard for 10+ minutes `[activity: stability-test]`
        - [ ] T4.2.2 Check eww logs for any poll errors `[activity: run-tests]`
        - [ ] T4.2.3 Verify all sensors continue updating `[activity: manual-test]`
        - [ ] T4.2.4 Test with WiFi disconnect/reconnect `[activity: edge-case-test]`
        - [ ] T4.2.5 Test with VPN connect/disconnect `[activity: edge-case-test]`

    - [ ] T4.3 Audio Integration Test
        - [ ] T4.3.1 Start cava daemon `[activity: integration-test]`
        - [ ] T4.3.2 Play music, verify visualizer animates `[activity: integration-test]`
        - [ ] T4.3.3 Stop music, verify visualizer shows standby `[activity: integration-test]`

    - [ ] T4.4 PRD Acceptance Criteria Verification
        - [ ] T4.4.1 Feature 1: Core Widget Framework - eww launches without errors ✓ `[ref: PRD/Feature 1]`
        - [ ] T4.4.2 Feature 2: Basic System Info - hostname, uptime, date display ✓ `[ref: PRD/Feature 2]`
        - [ ] T4.4.3 Feature 3: Workspace Indicators - active workspace highlighted ✓ `[ref: PRD/Feature 3]`
        - [ ] T4.4.4 Feature 4: Memory & Storage Bars - RAM/disk bars functional ✓ `[ref: PRD/Feature 4]`
        - [ ] T4.4.5 Feature 5: CPU Temperature - coretemp reading displays ✓ `[ref: PRD/Feature 5]`
        - [ ] T4.4.6 Feature 6: Fan Speed - both fans show RPM and spinner ✓ `[ref: PRD/Feature 6]`
        - [ ] T4.4.7 Feature 7: Network Interface - upload/download bars work ✓ `[ref: PRD/Feature 7]`
        - [ ] T4.4.8 Feature 8: Ping Latency - ping to 1.1.1.1 displays ✓ `[ref: PRD/Feature 8]`
        - [ ] T4.4.9 Feature 9: Audio Visualizer - ASCII visualizer animates ✓ `[ref: PRD/Feature 9]`
        - [ ] T4.4.10 Feature 10: Battery Status - percentage, status, time display ✓ `[ref: PRD/Feature 10]`
        - [ ] T4.4.11 Feature 11: Intel GPU - usage displays or N/A gracefully ✓ `[ref: PRD/Feature 11]`
        - [ ] T4.4.12 Feature 12: PCH Temperature - chipset temp displays ✓ `[ref: PRD/Feature 12]`
        - [ ] T4.4.13 Feature 13: NordVPN Status - connection state displays ✓ `[ref: PRD/Feature 13]`

    - [ ] T4.5 Documentation & Cleanup
        - [ ] T4.5.1 Update dotfiles/eww/README.md with T2-specific notes `[activity: document]`
        - [ ] T4.5.2 Remove or archive unused voltage scripts `[activity: cleanup]`
        - [ ] T4.5.3 Verify install.sh symlinks eww and cava correctly `[activity: review-code]`
        - [ ] T4.5.4 Test fresh install flow `[activity: integration-test]`

    - [ ] T4.6 Final Validation
        - [ ] T4.6.1 All 13 PRD features implemented `[activity: business-acceptance]`
        - [ ] T4.6.2 All 5 SDD ADRs followed `[activity: spec-compliance]`
        - [ ] T4.6.3 No errors in eww logs after 1 hour runtime `[ref: PRD/Success Metrics]`
        - [ ] T4.6.4 Dashboard loads on every Hyprland session start `[ref: PRD/Success Metrics]`

---

## Summary

| Phase | Focus | Tasks | Dependencies |
|-------|-------|-------|--------------|
| **Phase 1** | Core Foundation | 5 sub-tasks | None |
| **Phase 2** | T2 Sensor Rewiring | 4 parallel components | Phase 1 complete |
| **Phase 3** | T2 Enhancements | 4 parallel components | Phase 2 complete |
| **Phase 4** | Integration & Validation | Full E2E testing | Phase 3 complete |

**Parallel Work Opportunities:**
- Phase 2: Network, Fan, VPN, Audio can all be done in parallel
- Phase 3: Thermal, CPU Freq, Battery, Intel GPU can all be done in parallel

**Critical Path:**
1. Phase 1 must complete first (removes blocking errors)
2. Phase 2 fixes make dashboard functional
3. Phase 3 adds T2-specific value
4. Phase 4 validates everything works together
