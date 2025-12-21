# Specification: 004-eww-dashboard-t2-port

## Status

| Field | Value |
|-------|-------|
| **Created** | 2025-12-16 |
| **Current Phase** | Specification Complete - Ready for Implementation |
| **Last Updated** | 2025-12-16 |

## Documents

| Document | Status | Notes |
|----------|--------|-------|
| product-requirements.md | completed | All validation checks passed |
| solution-design.md | completed | All 5 ADRs confirmed by user |
| implementation-plan.md | completed | 4 phases, 13 PRD features mapped |

**Status values**: `pending` | `in_progress` | `completed` | `skipped`

## Decisions Log

| Date | Decision | Rationale |
|------|----------|-----------|
| 2025-12-16 | Dual fan display (Left/Right) | Keep separate displays for fan1 and fan2 for full visibility |
| 2025-12-16 | CPU + PCH thermal display | Show both CPU temp and chipset temp for comprehensive monitoring |
| 2025-12-16 | Adapt VPN to NordVPN CLI | User uses NordVPN, rewire from strongSwan to nordvpn command |
| 2025-12-16 | Elevate Could Have to Should Have | All T2 enhancements (Battery, iGPU, PCH, VPN) moved to Phase 2 - equally important |
| 2025-12-16 | ADR-1: Replace voltage widgets | Replace with CPU freq/governor and SSD temp instead of removing |
| 2025-12-16 | ADR-2: Fan naming | Use Left/Right instead of CPU/GPU for T2 dual fans |
| 2025-12-16 | ADR-3: Battery widget | Add dedicated battery widget |
| 2025-12-16 | ADR-4: VPN via NordVPN | Use nordvpn CLI instead of strongSwan |
| 2025-12-16 | ADR-5: Multi-thermal display | Create unified thermal section (CPU, PCH, SSD) |

## Context

**Project**: Port the EWW (Elkowar's Wacky Widgets) dashboard from the original Dionysus repository (ASUS-based) to Balder (MacBook Pro T2 with touchbar).

**Background Analysis Completed**:
- Identified 12+ components that work out-of-box
- Identified 5 components needing simple customization (network interface, audio source, fan/temp sensors)
- Identified 5 components needing extensive rework (voltage monitoring, GPU stats)
- Identified 3 unportable features (NVIDIA-specific, AMD sensor names)

**Phased Approach**:
1. **Phase 1**: Get bare minimum working (swap hardcoded values)
2. **Phase 2**: Rewire components to T2 Mac sensors
3. **Phase 3**: Remove/replace unportable widgets with T2-relevant alternatives

**T2 Hardware Context**:
- Intel Iris Plus Graphics 655 (iGPU, no discrete GPU)
- applesmc sensors: fan1, fan2, TC0E, TCGC, etc.
- coretemp-isa-0000: Package id 0, Core 0-3
- Network interface: wlan0 (not wlp4s0)
- Audio: PipeWire with alsa_output.pci-0000_02_00.3.Speakers.monitor

---
*This file is managed by the specification-management skill.*
