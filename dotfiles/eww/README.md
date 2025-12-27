# EWW Config 

───────────────────────────────────────────────  
 °˖* ૮( • ᴗ ｡)っ🍸 shheersh - Balder v1.0   
 ───────────────────────────────────────────────  

## Custom animated **EWW** HUD
A custom **eww (Elkowar's Wacky Widgets) HUD** for Linux — optimized for MacBook Pro T2 with ASCII art system stats, network monitoring, and neon reactor-core vibes.

![Eww Demo Png](../../assets/demo-eww.png)
---

## Features
  - **T2-optimized** - UPower-based power metrics, lm-sensors integration
  - **Synchronized ASCII fans** - Animated dual-fan display with Cyrillic units
  - **Network monitoring** - Download/upload bars, ping latency, VPN status
  - **CPU/RAM/Storage** - Real-time system resource bars
  - Атмосфера холодного цеха

![Eww Demo Gif](../../assets/demo-eww.gif)

```
eww/
├── eww.yuck                    # Main config with defpolls and includes
├── eww.scss                    # Stylesheet with theme variables
├── scripts/
│   ├── ascii/
│   │   └── ascii_core_layout.sh
│   ├── bar/
│   │   └── bar_render.sh
│   ├── net/
│   │   ├── net_download.sh
│   │   ├── net_download_bar.sh
│   │   ├── net_ping.sh
│   │   ├── net_ping_latency.sh
│   │   ├── net_upload.sh
│   │   ├── net_upload_bar.sh
│   │   ├── net_vpn.sh
│   │   ├── net_vpn_bar.sh
│   │   └── net_vpn_status.sh
│   └── sys/
│       ├── sys_cpu_voltage.sh
│       ├── sys_dc_voltage.sh
│       ├── sys_energy.sh       # Battery remaining Wh (UPower)
│       ├── sys_fan_bar.sh
│       ├── sys_fan_large.sh    # Animated ASCII fan art (spec-005)
│       ├── sys_fan_spin.sh
│       ├── sys_gpu_voltage.sh
│       └── sys_power_draw.sh   # Power draw with state indicator (UPower)
└── windows/
    ├── bar/
    │   └── cpu_ram_storage_bars.yuck
    ├── misc/
    │   └── welcome_text.yuck
    ├── net/
    │   ├── ascii_decor_frame.yuck
    │   └── net_bars.yuck
    └── sys/
        ├── fan_dashboard.yuck          # Unified fan + power widget (spec-005)
        ├── four_boxes.yuck
        └── workspace_window_text.yuck
```
 

## Requirements
  - **eww** (Elkowar's Wacky Widgets)
  - **lm-sensors** (for fan RPM, temps)
  - **upower** (for battery energy and power draw)
  - **jq** (for JSON parsing)
  - **curl** (for network checks)
  - **ping** (for latency monitoring)

---

## Usage
To launch the full HUD:

```bash
eww open-many ascii_decor_frame \
               cpu_ram_storage_bars \
               four_boxes \
               net_bars \
               fan_dashboard \
               welcome_text \
               workspace_window_text
```

**Automatic launch:** EWW is managed by [waybar_watcher.sh](../hypr/scripts/waybar_watcher.sh) which toggles between Waybar and EWW based on window activity.

### Configuration Notes

**T2 MacBook Pro:**
- Fan RPM via `lm-sensors` (applesmc module)
- Power metrics via `upower` (BAT0 device)
- Run `sensors-detect` once to configure lm-sensors

**Network scripts:**
- Default interface: `wlp4s0` - edit `net_*.sh` scripts if different
- VPN detection: NordVPN via nordvpn CLI

**For other hardware:**
- Some sys scripts (sys_gpu_voltage.sh) are AMD/NVIDIA specific - may need adaptation
- Check `sensors` output to verify available readings 

