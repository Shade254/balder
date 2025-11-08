# 🍸 Yazi File Manager - Complete Setup Guide

**Date**: 2025-11-08
**System**: MacBook Pro T2 (2560x1600 @ 1.25 scale) | Arch Linux | Hyprland | Alacritty-Sixel
**Status**: ✅ Fully configured and working!

---

## 📦 Installation

### Core Packages
```bash
sudo pacman -S yazi ffmpeg p7zip jq poppler fd ripgrep fzf imagemagick chafa
paru -S alacritty-sixel-git  # Replaces standard alacritty
```

### Why Alacritty-Sixel?
- **Standard Alacritty** + ueberzugpp = broken relative positioning (images don't follow preview pane)
- **Alacritty-Sixel** + Chafa = proper sixel protocol support with perfect relative positioning
- Images automatically follow the preview pane when you move/resize the window!

---

## 🎨 Theme & Configuration

### Nord-Inspired Color Scheme
- **Primary**: `#9cdef2` (light cyan)
- **Accent**: `#61afef` (blue)
- **Background**: `#282c34` (dark)
- Matches Alacritty, Hyprland, and system UI perfectly

### Configuration Files

**`~/.config/yazi/yazi.toml`** - Main configuration:
```toml
[mgr]
ratio = [1, 4, 3]              # Parent : Current : Preview pane layout
sort_by = "natural"            # Natural alphanumeric sorting
sort_dir_first = true          # Directories first
show_hidden = false            # Hide dotfiles by default (press 'i' to toggle)
linemode = "size"              # Show file sizes
scrolloff = 5                  # Keep 5 lines above/below cursor

[preview]
max_width = 1600               # MacBook Pro 2560x1600 resolution
max_height = 2000
image_filter = "lanczos3"      # High quality image scaling
image_quality = 75

# Image preview: Chafa with Sixel protocol (auto-detected)
# No manual offset/scale needed - images follow preview pane!

[opener]
# Smart editor detection
edit = [{ run = 'nano "$@"', block = true }]
code = [{ run = 'cursor "$@"', orphan = true }]
image = [{ run = 'imv "$@"', orphan = true }]
video = [{ run = 'vlc "$@"', orphan = true }]

[open]
rules = [
    # Code files → Cursor
    { name = "*.{rs,py,js,ts,jsx,tsx,go,lua,vim,sh}", use = "code" },
    # Config/text → nano
    { name = "*.{txt,md,conf,toml,yaml,json,ini}", use = "edit" },
    # Media
    { mime = "image/*", use = "image" },
    { mime = "video/*", use = "video" },
]
```

**`~/.config/yazi/theme.toml`** - Colors:
```toml
[mgr]
cwd = { fg = "#9cdef2", bold = true }
hovered = { bg = "#3e4451" }

[filetype]
rules = [
    { mime = "inode/directory", fg = "#61afef", bold = true },
    { mime = "text/*", fg = "#9cdef2" },
    { name = "*.py", fg = "#e5c07b" },
    { name = "*.rs", fg = "#e06c75" },
    { name = "*.js", fg = "#e5c07b" },
    # ... extensive file type mappings
]

[status]
mode_normal = { fg = "#282c34", bg = "#61afef", bold = true }
separator_style = { fg = "#61afef", bg = "#282c34" }
```

**`~/.config/yazi/keymap.toml`** - Keybindings:
```toml
[mgr]
prepend_keymap = [
    # Fixed defaults
    { on = "i", run = "hidden toggle", desc = "Toggle hidden files" },
    { on = "/", run = "search --via=fd", desc = "Search files" },
    { on = "e", run = "open", desc = "Open file" },
    { on = "b", run = "plugin toggle-pane min-preview", desc = "Toggle preview" },

    # Custom keybinds
    { on = "c", run = 'shell "cursor $@" --block --confirm', desc = "Open in Cursor" },
    { on = "n", run = 'shell "nano $@" --block --confirm', desc = "Edit with nano" },
    { on = "w", run = 'shell "echo -n $0 | wl-copy" --block --confirm', desc = "Copy path" },
    { on = "f", run = 'shell "basename $0 | wl-copy" --block --confirm', desc = "Copy filename" },
    { on = "o", run = 'shell "thunar $PWD &" --confirm', desc = "Open Thunar" },
]
```

---

## ⌨️ Keybindings Reference

### Your Custom Keys
| Key | Action | Description |
|-----|--------|-------------|
| **`c`** | Open in Cursor | Opens code files in Cursor editor |
| **`n`** | Edit with nano | Quick edit config/text files |
| **`w`** | Copy path | Full path to clipboard (wl-copy) |
| **`f`** | Copy filename | Just the filename, not full path |
| **`o`** | Open Thunar | GUI file manager in current dir |

### Fixed Defaults
| Key | Action |
|-----|--------|
| **`i`** | Toggle hidden files (dotfiles) |
| **`/`** | Search files by name (fd) |
| **`e`** | Open with default app |
| **`b`** | Toggle preview pane visibility |
| **`r`** | Rename file |
| **`a`** | Create file (add `/` for folder) |

### File Operations
| Key | Action |
|-----|--------|
| **`y`** | Yank (copy) |
| **`x`** | Cut |
| **`p`** | Paste |
| **`d`** | Delete (trash) |
| **`D`** | Delete (permanent) |
| **`Space`** | Select/deselect |
| **`v`** | Visual mode (multi-select) |

### Navigation
| Key | Action |
|-----|--------|
| **`h`** / `←` | Parent directory |
| **`j`** / `↓` | Move down |
| **`k`** / `↑` | Move up |
| **`l`** / `→` / `Enter` | Enter directory / Open file |
| **`gg`** | Jump to top |
| **`G`** | Jump to bottom |
| **`~`** | Go home |

### Search & View
| Key | Action |
|-----|--------|
| **`/`** | Search files (fd) |
| **`s`** | Search files (alternative) |
| **`S`** | Search file contents (ripgrep) |
| **`i`** | Toggle hidden files |
| **`z`** | fzf fuzzy finder |

### Tabs
| Key | Action |
|-----|--------|
| **`t`** | New tab |
| **`Tab`** | Next tab |
| **`1-9`** | Jump to tab number |

---

## 🚀 Usage

### Launch Yazi
```bash
# Terminal command (cd-on-exit enabled)
y

# Hyprland keybind
Super + E
```

### cd-on-exit Function
Added to `~/.zshrc`:
```bash
function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}
```

When you quit Yazi (press `q`), your terminal `cd`'s to the last directory you were in!

---

## 🖼️ Image Preview Details

### How It Works
1. **Alacritty-Sixel** provides sixel graphics protocol support
2. **Chafa** (already installed) detects sixel and renders pixel-perfect images
3. **Yazi** auto-detects the capability and uses Chafa for preview
4. **Result**: Images follow the preview pane perfectly (relative positioning!)

### Troubleshooting
If images don't appear:
```bash
# Check adapters are available
yazi --debug | grep -E "chafa|ueberzugpp"

# Should show:
# chafa         : 1.16.2
# ueberzugpp    : 2.9.8
```

### Why This Setup?
- **Old approach**: ueberzugpp with manual offset tuning → broke on window resize/move
- **New approach**: Chafa + sixel → automatic relative positioning, no manual calibration needed!

---

## 📁 File Structure

```
~/.config/yazi/
├── yazi.toml          # Main config (sorting, preview, openers)
├── theme.toml         # Nord colors and file type colors
└── keymap.toml        # Custom keybindings

~/balder/dotfiles/
├── alacritty/
│   └── alacritty.toml # Alacritty-sixel config (theme matches Yazi)
├── hypr/
│   └── hyprland.conf  # Super+E launches Yazi
└── zsh/
    └── .zshrc         # cd-on-exit function and prompt

~/.local/state/yazi/packages/
└── toggle-pane.yazi/  # Official plugin for preview toggle
```

---

## 🎯 Common Workflows

### Copy Files
1. Navigate to file → press **`y`** (yank)
2. Navigate to destination → press **`p`** (paste)

### Copy Path to Clipboard
1. Navigate to file → press **`w`**
2. Paste anywhere with `Ctrl+Shift+V`

### Open in Cursor
1. Navigate to code file → press **`c`**
2. Cursor opens the file

### Quick Edit Config
1. Navigate to `.conf`/`.toml` → press **`n`**
2. Edit in nano, save with `Ctrl+O`, `Enter`, `Ctrl+X`

### Search Files
1. Press **`/`**
2. Type search term
3. Navigate results

### Create File/Folder
- **File**: Press **`a`** → type `myfile.txt` → Enter
- **Folder**: Press **`a`** → type `myfolder/` → Enter (note trailing `/`)

---

## 🔧 Technical Notes

### Alacritty-Sixel vs Standard Alacritty
- **Binary**: `/usr/bin/alacritty` (same location)
- **Config**: 100% compatible with standard Alacritty config
- **Difference**: Adds sixel graphics protocol support
- **Provides**: `alacritty` package (replaces it)

### Why Not Use ueberzugpp?
ueberzugpp works with Kitty/Foot terminals that report pixel dimensions via CSI escape sequences. Alacritty doesn't support this (`width: 0, height: 0` in debug), so ueberzugpp falls back to absolute screen positioning:
- **Problem**: Image stays at fixed screen coordinates when you move/resize window
- **Solution**: Use sixel protocol instead (relative to terminal cells, not screen pixels)

### Monitor Configuration
- **Display**: 2560x1600 @ 1.25 Hyprland scale
- **Preview settings**: `max_width = 1600`, `max_height = 2000`
- Adjust these if you change monitor/scaling

---

## 📊 System Integration

### Hyprland
```conf
# ~/balder/dotfiles/hypr/hyprland.conf
bind = SUPER, E, exec, alacritty -e yazi
```

### Zsh Prompt
Shows current directory:
```zsh
PROMPT='%F{cyan}arch_t2_miro%f %F{blue}%~%f %F{black}❯%f '
```

---

## ✅ What's Working

- ✅ **Image preview** with proper relative positioning (Chafa + Sixel)
- ✅ **Preview toggle** (`b` key) using official plugin
- ✅ **Hidden files** hidden by default (toggle with `i`)
- ✅ **Nord theme** matching system aesthetic
- ✅ **Smart file opening** (nano for configs, Cursor for code)
- ✅ **cd-on-exit** functionality
- ✅ **Custom keybinds** for workflow optimization
- ✅ **Clipboard integration** (copy path/filename)

---

## 🎉 Final Result

A beautiful, productivity-focused file manager that:
- Matches your Nord-inspired system theme perfectly
- Opens code files in Cursor, configs in nano automatically
- Previews images with proper positioning (follows preview pane!)
- Integrates with system clipboard (Wayland wl-copy)
- Changes terminal directory on exit
- Launches with Super+E from anywhere

**🍸 Everything works! Enjoy your beautiful, productive file manager!**
