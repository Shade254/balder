# Specification: 005-eww-fan-dashboard-redesign

## Status

| Field | Value |
|-------|-------|
| **Created** | 2025-12-27 |
| **Current Phase** | PLAN Complete - Ready for Implementation |
| **Last Updated** | 2025-12-27 |
| **Branch** | `005-eww-fan-dashboard-redesign` (from `004-eww-dashboard-t2-port`) |

## Documents

| Document | Status | Notes |
|----------|--------|-------|
| product-requirements.md | completed | All sections filled, decisions logged |
| solution-design.md | completed | All ADRs confirmed |
| implementation-plan.md | completed | 4 phases, 17 task groups defined |

**Status values**: `pending` | `in_progress` | `completed` | `skipped`

## Decisions Log

| Date | Decision | Rationale |
|------|----------|-----------|
| 2025-12-27 | Branch 005 from 004 | Keep all EWW work together without merging incomplete 004 to main |
| 2025-12-27 | Single combined window | Codebase trend toward consolidation; recent commit merged 2→1 windows |
| 2025-12-27 | Power Draw (W) + Energy (Wh) | Most useful metrics for daily use; answers "draining fast?" and "how much left?" |
| 2025-12-27 | Arrow + color for charging state | ↑ green for charging, ↓ orange for discharging - visual and intuitive |
| 2025-12-27 | Cyrillic units (об/мин, Вт·ч) | Consistent with existing dashboard aesthetic |
| 2025-12-27 | Fan size: 3-5 lines tall | Compact but visible, not overwhelming |
| 2025-12-27 | Layout: Fan-Metrics-Fan | Horizontal arrangement with metrics in center |
| 2025-12-27 | Borderless widget | Clean floating elements, no ASCII box frame |
| 2025-12-27 | Full Cyrillic labels | "мощность:" and "энергия:" prefixes on metrics |
| 2025-12-27 | Delete old widgets | Remove 3 broken widgets after new one works |
| 2025-12-27 | Use existing theme | Must use $color-primary, $color-secondary, etc. from eww.scss |
| 2025-12-27 | Animation interval 0.3s | Balanced smoothness vs CPU efficiency for large ASCII |

## Context

**Problem**: The current power/cooling widgets (`power_mode_text.yuck`, `power_cooling_header_text.yuck`, `right_fan_data.yuck`) are:
- Unfunctional (AMD-specific sensors don't exist on T2 Mac)
- Ill-defined (missing `show_eww` variable, inconsistent styling)
- Not styled correctly

**Vision**: Create a brand new unified fan dashboard with:
- Big ASCII spinning fans (left and right)
- RPM numbers under each fan with Cyrillic units (об/мин)
- Relevant energy metrics in between or below

**Open Questions** (to resolve in PRD):
1. One, two, or three EWW windows?
2. What energy metrics are relevant on T2 Mac? (Input/Output/Battery-stored?)

**Platform**: T2 MacBook Pro (Intel + Apple T2 chip)
- Available sensors: `fan1:`, `fan2:` (applesmc), `in0:` battery voltage, `curr1:` battery current
- Missing sensors: `vddgfx`, `vddnb`, `power1:` (AMD-specific)

---
*This file is managed by the specification-management skill.*
