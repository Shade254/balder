# 🗂️ Yazi Quick Reference Guide

**Version**: Yazi 25.5.31
**System**: Arch Linux + Hyprland
**Updated**: 2025-11-08

---

## 🎯 Quick Start (30 Second Intro)

```bash
# Launch Yazi
yazi

# Basic navigation
hjkl or arrow keys  # Move around
Enter or l          # Open file/enter directory
h or Esc           # Go back/up one directory
q                  # Quit

# That's enough to get started!
```

---

## ⌨️ Essential Keybindings (The Must-Knows)

### Navigation (Vim-style)

| Key | Action | Example |
|-----|--------|---------|
| `h` | Go to parent directory | Go up one level |
| `j` | Move down | Next file |
| `k` | Move up | Previous file |
| `l` or `Enter` | Open file/directory | Open selected item |
| `gg` | Jump to top | First file in list |
| `G` | Jump to bottom | Last file in list |
| `5j` | Move down 5 items | Jump 5 files down |
| `50%` | Jump to 50% of list | Middle of file list |
| `Arrow keys` | Also work! | Same as hjkl |

### File Operations (The Power Moves)

| Key | Action | Description |
|-----|--------|-------------|
| `y` | Yank (copy) | Copy selected files |
| `x` | Cut | Cut selected files |
| `p` | Paste | Paste copied/cut files |
| `d` | Delete | Move to trash (safe) |
| `D` | Force delete | Permanent delete |
| `r` | Rename | Rename current file |
| `a` | Create file | Create new file |
| `A` | Create directory | Create new folder |

### Selection (Bulk Operations)

| Key | Action | Description |
|-----|--------|-------------|
| `Space` | Toggle selection | Select/deselect current file |
| `v` | Visual mode | Start visual selection |
| `V` | Visual mode (unset) | Clear visual selection |
| `Ctrl+a` | Select all | Select all files in current dir |
| `Ctrl+r` | Reverse selection | Invert selection |

### Search & Filter

| Key | Action | Description |
|-----|--------|-------------|
| `/` | Search | Search files by name |
| `n` | Next match | Jump to next search result |
| `N` | Previous match | Jump to previous search result |
| `f` | Filter | Filter files (show only matches) |
| `Ctrl+s` | Search by content | Full-text search (with ripgrep) |

### Tabs & Panes

| Key | Action | Description |
|-----|--------|-------------|
| `t` | New tab | Create new tab |
| `Tab` | Next tab | Switch to next tab |
| `Shift+Tab` | Previous tab | Switch to previous tab |
| `1-9` | Jump to tab | Jump to tab 1-9 |
| `[` | Previous tab | Alternative tab switching |
| `]` | Next tab | Alternative tab switching |

### Preview & View Modes

| Key | Action | Description |
|-----|--------|-------------|
| `z` | Toggle preview | Show/hide preview pane |
| `i` | Toggle hidden files | Show/hide dotfiles |
| `s` | Sort menu | Change sort order |
| `S` | Symlink creation | Create symbolic link |

### Shell & Commands

| Key | Action | Description |
|-----|--------|-------------|
| `:` | Command mode | Run Yazi commands |
| `!` | Shell command | Run shell command |
| `Enter` (on file) | Open with default app | Uses xdg-open |
| `o` | Open with... | Choose application |

### Help & Navigation

| Key | Action | Description |
|-----|--------|-------------|
| `?` or `F1` | Help menu | Show all keybindings |
| `~` | Go to home | Jump to home directory |
| `g` then key | Go to shortcuts | See "Go to" section below |

---

## 🎯 "Go To" Shortcuts (Press `g` then...)

| After `g` press | Go to | Example |
|----------------|-------|---------|
| `h` | Home directory | ~/  |
| `c` | Config directory | ~/.config |
| `d` | Downloads | ~/Downloads |
| `t` | Trash | ~/.trash |
| `/` | Root | / |
| `.` | Current directory | Refresh view |

---

## 📂 File Operations Workflow Examples

### Copy Files to Another Directory

```
1. Navigate to source files
2. Space to select files (or v for visual mode)
3. y to yank (copy)
4. Navigate to destination (hjkl)
5. p to paste
```

### Move Files (Cut & Paste)

```
1. Select files with Space
2. x to cut
3. Navigate to destination
4. p to paste
```

### Bulk Rename

```
1. Select multiple files (Space or v)
2. r for bulk rename
3. Opens editor with filenames
4. Edit filenames as needed
5. Save and close editor
```

### Delete Files Safely

```
1. Navigate to file
2. d to delete (moves to trash - safe!)
3. Confirm with y

Or for permanent delete:
1. D (capital D) for force delete
2. Confirm with y
```

### Create New File/Folder

```
New file:
1. a (lowercase)
2. Type filename
3. Enter

New folder:
1. A (uppercase)
2. Type folder name
3. Enter
```

---

## ⚙️ Configuration Files

Yazi uses 4 main config files in `~/.config/yazi/`:

### 1. `yazi.toml` - General Configuration

**Purpose**: App behavior, features, performance

**Key settings**:
```toml
[manager]
ratio = [1, 4, 3]  # Pane ratios (parent:current:preview)
sort_by = "modified"  # Sort by: "modified", "alphabetical", "natural", "size"
sort_reverse = false
sort_dir_first = true
show_hidden = false
show_symlink = true

[preview]
tab_size = 2
max_width = 600
max_height = 900
cache_dir = ""  # Leave empty to use default

[opener]
# Default applications for file types
edit = [
    { exec = 'nvim "$@"', block = true },
]
play = [
    { exec = 'mpv "$@"', orphan = true },
]
open = [
    { exec = 'xdg-open "$@"', desc = "Open with default app" },
]

[open]
rules = [
    { mime = "text/*", use = "edit" },
    { mime = "video/*", use = "play" },
    { mime = "audio/*", use = "play" },
    { mime = "image/*", use = "open" },
]
```

### 2. `keymap.toml` - Custom Keybindings

**Purpose**: Customize or add keybindings

**Example**:
```toml
[manager]
prepend_keymap = [
    # Custom keybinds (don't override defaults)
    { on = [ "T" ], exec = "shell thunar . &", desc = "Open in Thunar" },
    { on = [ "e" ], exec = "shell nvim $@", desc = "Edit in Neovim" },
    { on = [ "m" ], exec = "shell mpv $@", desc = "Play with mpv" },
]

# Override default keybinds
keymap = [
    { on = [ "q" ], exec = "quit", desc = "Exit Yazi" },
]
```

### 3. `theme.toml` - Colors & Appearance

**Purpose**: Customize colors, icons, UI

**Your Nord theme** (see next section!)

### 4. `init.lua` - Lua Plugins & Scripts

**Purpose**: Advanced customization with Lua

**Example**:
```lua
-- Custom plugins and scripts go here
-- More on this in plugins section
```

---

## 🎨 Your Nord Theme Configuration

Let me create your perfect Nord theme!

**File**: `~/.config/yazi/theme.toml`

```toml
# ─────────────────────────────────────────────────────────────────────────
#  °˖* ૮(  • ᴗ ｡)っ🍸  Nord-Inspired Neon Theme for Yazi
#  Matches your Alacritty aesthetic
# ─────────────────────────────────────────────────────────────────────────

[manager]
cwd = { fg = "#9cdef2", bold = true }  # Current directory - light cyan

# Highlighting in file list
hovered = { bg = "#3e4451" }  # Hovered item background
preview_hovered = { bg = "#3e4451" }  # Preview hovered

# File types (Nord-inspired)
[filetype]
rules = [
    # Directories
    { mime = "inode/directory", fg = "#61afef", bold = true },  # Blue directories

    # Documents
    { mime = "text/*", fg = "#9cdef2" },  # Light cyan text
    { name = "*.md", fg = "#9cdef2" },
    { name = "*.txt", fg = "#9cdef2" },

    # Code
    { name = "*.py", fg = "#e5c07b" },  # Yellow
    { name = "*.js", fg = "#e5c07b" },
    { name = "*.rs", fg = "#e06c75" },  # Red
    { name = "*.go", fg = "#61afef" },  # Blue
    { name = "*.sh", fg = "#98c379" },  # Green

    # Archives
    { name = "*.zip", fg = "#c678dd" },  # Magenta
    { name = "*.tar", fg = "#c678dd" },
    { name = "*.gz", fg = "#c678dd" },

    # Images
    { mime = "image/*", fg = "#56b6c2" },  # Cyan

    # Videos
    { mime = "video/*", fg = "#c678dd" },  # Magenta

    # Audio
    { mime = "audio/*", fg = "#c678dd" },  # Magenta
]

[status]
separator_open = ""
separator_close = ""
separator_style = { fg = "#61afef", bg = "#282c34" }  # Blue separator

# Mode indicators
mode_normal = { fg = "#282c34", bg = "#61afef", bold = true }  # Blue normal mode
mode_select = { fg = "#282c34", bg = "#9cdef2", bold = true }  # Cyan select mode
mode_unset = { fg = "#282c34", bg = "#e06c75", bold = true }  # Red unset mode

# Progress bar
progress_label = { fg = "#9cdef2", bold = true }
progress_normal = { fg = "#61afef", bg = "#3e4451" }
progress_error = { fg = "#e06c75", bg = "#3e4451" }

# Permissions display
permissions_t = { fg = "#98c379" }  # Green
permissions_r = { fg = "#e5c07b" }  # Yellow
permissions_w = { fg = "#e06c75" }  # Red
permissions_x = { fg = "#61afef" }  # Blue
permissions_s = { fg = "#c678dd" }  # Magenta

[select]
border = { fg = "#61afef" }  # Blue border
active = { fg = "#9cdef2", bold = true }  # Light cyan active
inactive = { fg = "#828997" }  # Gray inactive

[input]
border = { fg = "#61afef" }  # Blue border
title = { fg = "#9cdef2" }  # Light cyan title
value = { fg = "#9cdef2" }  # Light cyan input
selected = { bg = "#3e4451" }  # Selection background

[completion]
border = { fg = "#61afef" }  # Blue border
active = { bg = "#3e4451" }  # Active item background
inactive = {}

[tasks]
border = { fg = "#61afef" }  # Blue border
title = { fg = "#9cdef2" }  # Light cyan title
hovered = { bg = "#3e4451" }  # Hovered task background

[which]
cols = 3
mask = { bg = "#282c34" }
cand = { fg = "#9cdef2" }  # Light cyan candidates
rest = { fg = "#828997" }  # Gray rest
desc = { fg = "#61afef" }  # Blue description
separator = "  "
separator_style = { fg = "#444444" }

[help]
on = { fg = "#9cdef2" }  # Light cyan key
exec = { fg = "#61afef" }  # Blue command
desc = { fg = "#828997" }  # Gray description
hovered = { bg = "#3e4451" }  # Hovered help item

[notify]
title_info = { fg = "#61afef" }  # Blue info
title_warn = { fg = "#e5c07b" }  # Yellow warning
title_error = { fg = "#e06c75" }  # Red error
```

---

## 🔌 Plugins & Extensions

Yazi has a powerful plugin system written in Lua!

### Plugin Manager: `ya`

Yazi includes `ya` - the official package manager for plugins and flavors.

```bash
# List installed plugins
ya pack list

# Install a plugin
ya pack install <author/repo>

# Update plugins
ya pack upgrade

# Remove plugin
ya pack remove <name>
```

### Recommended Plugins

#### 1. **File Actions**
```bash
# Jump plugin - fast directory jumping (like autojump)
ya pack install yazi-rs/plugins:jump

# Chmod plugin - change permissions easily
ya pack install yazi-rs/plugins:chmod

# Archive plugin - better archive handling
ya pack install yazi-rs/plugins:archive
```

#### 2. **Productivity Boosters**
```bash
# Git integration - show git status in file list
ya pack install yazi-rs/plugins:git

# Jump to projects plugin
ya pack install yazi-rs/plugins:projects

# Smart filter plugin
ya pack install yazi-rs/plugins:smart-filter
```

#### 3. **Themes (Flavors)**
```bash
# Browse available themes
ya pack search flavor

# Install Nord-like flavors
ya pack install catppuccin/yazi  # Catppuccin theme (similar to Nord)
ya pack install yazi-rs/flavors:nord  # If available
```

### Creating Custom Plugins

**Example**: Quick image optimization

Create `~/.config/yazi/plugins/optimize-image.yazi/init.lua`:

```lua
return {
  entry = function(_, args)
    local h = cx.active.current.hovered
    if h and h.url then
      local path = tostring(h.url)
      if path:match("%.png$") or path:match("%.jpg$") then
        ya.manager_emit("shell", {
          "optipng " .. path,
          block = true,
          confirm = true,
        })
      end
    end
  end,
}
```

Then add keybinding in `keymap.toml`:
```toml
{ on = [ "O" ], exec = "plugin optimize-image", desc = "Optimize image" }
```

---

## 🚀 Advanced Features

### 1. Shell Integration (CD on Exit)

Add to your `~/.zshrc`:

```bash
# Yazi - cd on exit
function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}
```

Now use `y` instead of `yazi` to cd into directories when you quit!

### 2. Image Preview

Yazi supports multiple image preview protocols:

**For terminals that support it** (Kitty, WezTerm, iTerm2):
- Images preview automatically!

**For Alacritty** (doesn't support image protocol):
```toml
# In yazi.toml
[preview]
image_filter = "lanczos3"
image_quality = 75
```

Use `ueberzug++` for image previews:
```bash
sudo pacman -S ueberzug
```

### 3. Bookmarks

```bash
# Press m to set bookmark
m a  # Bookmark as 'a'
m b  # Bookmark as 'b'

# Press ' to jump to bookmark
' a  # Jump to bookmark 'a'
' b  # Jump to bookmark 'b'
```

Configure in `~/.config/yazi/yazi.toml`:
```toml
[bookmark]
enabled = true
```

### 4. Batch Renaming with Editor

```bash
# Select files (Space or v)
# Press r for bulk rename
# Yazi opens your $EDITOR with all filenames
# Edit the names
# Save and quit editor
# Yazi renames all files!
```

Set your preferred editor:
```bash
# In .zshrc
export EDITOR=nvim  # or vim, nano, etc.
```

---

## 🎯 Pro Tips & Tricks

### Workflow Optimization

**1. Use tabs for different tasks**:
```
t - new tab for downloads
t - new tab for projects
t - new tab for documents
Use 1, 2, 3 to switch between them
```

**2. Visual mode for bulk operations**:
```
v - enter visual mode
jjjjj - select 5 files
y - yank all
```

**3. Quick directory jumping**:
```
~ - home
/ - search, type name, enter
gg - top, G - bottom
```

**4. Preview while navigating**:
```
Keep preview open (z to toggle)
Navigate with j/k
Preview updates automatically
```

### Performance Tips

**1. Disable expensive previews for large directories**:
```toml
# In yazi.toml
[preview]
max_width = 600
max_height = 900
# Don't preview files larger than 10MB
max_size = 10485760
```

**2. Cache directory for faster previews**:
```toml
[preview]
cache_dir = "~/.cache/yazi"
```

**3. Limit git status checks**:
```toml
[plugin]
git_status = { max_entries = 5000 }
```

---

## 🔧 Integration with Your Hyprland Setup

### Add Yazi Keybindings to Hyprland

Edit `~/balder/dotfiles/hypr/hyprland.conf`:

```bash
# File manager keybinds
bind = SUPER, E, exec, alacritty -e yazi
bind = SUPER SHIFT, E, exec, thunar  # Fallback GUI

# Or use a dedicated terminal class for Yazi
bind = SUPER, E, exec, alacritty --class yazi-fm -e yazi
```

### Window Rules for Yazi

```bash
# Optional: Float Yazi windows
windowrulev2 = float, class:^(yazi-fm)$
windowrulev2 = size 80% 80%, class:^(yazi-fm)$
windowrulev2 = center, class:^(yazi-fm)$
```

### Quick Access Script

Create `~/.config/hypr/scripts/yazi-launcher.sh`:

```bash
#!/bin/bash
# Launch Yazi in specific directory based on context

if [ -n "$1" ]; then
    # Open in specified directory
    alacritty -e yazi "$1"
elif [ -d ~/Downloads ]; then
    # Default to Downloads
    alacritty -e yazi ~/Downloads
else
    # Default to home
    alacritty -e yazi ~
fi
```

Make executable:
```bash
chmod +x ~/.config/hypr/scripts/yazi-launcher.sh
```

---

## 📚 Learning Path

### Week 1: Basics
- [ ] Learn hjkl navigation
- [ ] Practice y/x/p (copy/cut/paste)
- [ ] Use search (/)
- [ ] Toggle hidden files (i)

### Week 2: Productivity
- [ ] Master visual mode (v)
- [ ] Use tabs (t, Tab, 1-9)
- [ ] Set bookmarks (m, ')
- [ ] Practice bulk rename (r)

### Week 3: Advanced
- [ ] Install plugins
- [ ] Customize theme
- [ ] Create custom keybindings
- [ ] Write a simple plugin

### Week 4: Mastery
- [ ] Zero mouse usage
- [ ] Custom workflows
- [ ] Shell integration
- [ ] Teach someone else!

---

## 🆘 Common Issues & Solutions

### Problem: Preview not showing images

**Solution**:
```bash
# Install preview dependencies
sudo pacman -S ffmpegthumbnailer ueberzug poppler imagemagick
```

### Problem: Can't open files in default app

**Solution**:
```bash
# Make sure xdg-utils is installed
sudo pacman -S xdg-utils

# Set default applications
xdg-mime default thunar.desktop inode/directory
```

### Problem: Keybindings not working

**Solution**:
- Check syntax in `keymap.toml`
- Restart Yazi (q and relaunch)
- Check for conflicts with terminal keybindings

### Problem: Slow performance in large directories

**Solution**:
```toml
# In yazi.toml
[manager]
# Limit number of files to load
limit = 10000

[preview]
# Disable preview for very large files
max_size = 5242880  # 5MB
```

---

## 🎓 Resources

### Official Documentation
- Docs: https://yazi-rs.github.io/docs/
- GitHub: https://github.com/sxyazi/yazi
- Plugins: https://yazi-rs.github.io/docs/plugins/overview

### Community
- r/unixporn - Aesthetic inspiration
- Yazi Discord - Active community
- GitHub Issues - Bug reports and features

### Video Tutorials
- Search YouTube: "Yazi file manager tutorial"
- r/commandline - CLI tips and tricks

---

## ⚡ Quick Reference Card

**Must-Know Keybinds** (print this!):

```
NAVIGATION          FILES               SELECTION
h  - parent dir     y  - copy          Space - toggle
j  - down          x  - cut           v     - visual mode
k  - up            p  - paste         Ctrl+a - select all
l  - open/enter    d  - delete
gg - top           r  - rename        SEARCH
G  - bottom        a  - new file      /  - search
                   A  - new folder    n  - next result
TABS
t  - new tab       VIEW               HELP
1-9 - jump tab     z  - preview       ?  - help
Tab - next         i  - hidden        q  - quit
```

---

**Ready to configure Yazi with your Nord theme? Let me set it up for you!** 🍸
