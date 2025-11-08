# 🎨 tuigreet Theme Customization Guide

Complete guide to customizing your tuigreet login screen to match your Alacritty aesthetic.

---

## Current Theme: Nord-Inspired Neon-Accent

Your tuigreet is configured to match your Alacritty color scheme:

| Element | Alacritty Color | tuigreet Setting |
|---------|----------------|------------------|
| **Background** | `#282c34` (dark) | `container=black` |
| **Main Text** | `#9cdef2` (light cyan) | `text=lightcyan` |
| **Time Display** | `#9cdef2` (light cyan) | `time=lightcyan` |
| **Borders** | `#61afef` (blue) | `border=blue` |
| **Prompts** | `#61afef` (blue) | `prompt=blue` |
| **User Input** | `#9cdef2` (light cyan) | `input=lightcyan` |
| **Greeting** | `#9cdef2` (light cyan) | `greet=lightcyan` |
| **Actions/Buttons** | `#61afef`/`#9cdef2` | `action=blue;button=cyan` |

---

## Theme Component Reference

### Available Components

| Component | What It Controls | Example |
|-----------|-----------------|---------|
| **text** | Base text color for UI elements | `text=lightcyan` |
| **time** | Date and time display | `time=lightcyan` |
| **container** | Background color for centered containers | `container=black` |
| **border** | Container border colors | `border=blue` |
| **title** | Container title colors | `title=lightcyan` |
| **greet** | Issue or greeting message text | `greet=lightcyan` |
| **prompt** | Prompt labels like "Username:" | `prompt=blue` |
| **input** | User input feedback coloring | `input=lightcyan` |
| **action** | Action descriptions at screen bottom | `action=blue` |
| **button** | Keybinding indicators | `button=cyan` |

---

## Available ANSI Colors

tuigreet supports these ANSI color names:

### Basic Colors
- `black`
- `red`
- `green`
- `yellow`
- `blue`
- `magenta`
- `cyan`
- `white`
- `gray` (or `grey`)
- `darkgray` (or `darkgrey`)

### Light/Bright Colors
- `lightred`
- `lightgreen`
- `lightyellow`
- `lightblue`
- `lightmagenta`
- `lightcyan`
- `lightgray` (or `lightgrey`)

---

## Your Alacritty Color Palette (Reference)

From `dotfiles/alacritty/alacritty.toml`:

```toml
[colors.primary]
background = "#282c34"  # Dark background
foreground = "#9cdef2"  # Light cyan text

[colors.normal]
black   = "#2e3440"
red     = "#e06c75"
green   = "#9cdef2"  # Mapped to cyan!
yellow  = "#e5c07b"
blue    = "#61afef"
magenta = "#c678dd"
cyan    = "#9cdef2"
white   = "#828997"

[colors.cursor]
cursor = "#528bff"  # Blue
text   = "#9cdef2"  # Light cyan
```

---

## Customization Examples

### Example 1: More Blue Accent
If you want to emphasize blue more:

```toml
command = "tuigreet --time --remember --remember-session --asterisks --theme 'text=lightcyan;time=blue;border=blue;prompt=blue;input=blue;action=blue;button=blue;container=black;greet=lightcyan' --cmd Hyprland"
```

### Example 2: Minimalist White/Gray
For a cleaner, minimalist look:

```toml
command = "tuigreet --time --remember --remember-session --asterisks --theme 'text=white;time=lightgray;border=darkgray;prompt=white;input=white;action=gray;button=white;container=black' --cmd Hyprland"
```

### Example 3: Cyberpunk Magenta
For a more vibrant cyberpunk aesthetic:

```toml
command = "tuigreet --time --remember --remember-session --asterisks --theme 'text=lightmagenta;time=lightcyan;border=magenta;prompt=lightmagenta;input=lightcyan;action=magenta;button=lightcyan;container=black' --cmd Hyprland"
```

### Example 4: Warm Yellow/Orange (Limited by ANSI)
For a warmer feel (limited to ANSI colors):

```toml
command = "tuigreet --time --remember --remember-session --asterisks --theme 'text=white;time=yellow;border=yellow;prompt=yellow;input=white;action=yellow;button=white;container=black' --cmd Hyprland"
```

---

## Additional tuigreet Options

### Features Already Enabled

Your current config uses:
- `--time` - Show current time
- `--remember` - Remember last username
- `--remember-session` - Remember last session
- `--asterisks` - Show asterisks when typing password
- `--greet-align center` - Center the greeting message

### Optional Features You Can Add

#### User Selection Menu
Add graphical user selection:
```bash
--user-menu
```

#### Custom Greeting
Replace default greeting:
```bash
--greeting "Welcome to Dionysus"
```

#### Custom Asterisk Characters
Use different characters for password masking:
```bash
--asterisks-char '•'
```

#### Window Padding
Add padding around the terminal area:
```bash
--window-padding 2
```

#### Container Padding
Add padding inside the main prompt:
```bash
--container-padding 2
```

---

## How to Apply Theme Changes

### Method 1: Update dotfiles and deploy (Recommended)

1. Edit the theme in `dotfiles/greetd/config.toml`
2. Copy to system location:
   ```bash
   sudo cp dotfiles/greetd/config.toml /etc/greetd/config.toml
   ```
3. Reboot to see changes:
   ```bash
   sudo reboot
   ```

### Method 2: Quick test (temporary)

1. Edit `/etc/greetd/config.toml` directly:
   ```bash
   sudo nano /etc/greetd/config.toml
   ```
2. Save and reboot
3. If you like it, copy back to dotfiles:
   ```bash
   cp /etc/greetd/config.toml ~/balder/dotfiles/greetd/config.toml
   ```

---

## Theme Builder Template

Copy and customize this template in `config.toml`:

```toml
[default_session]
command = "tuigreet \
    --time \
    --remember \
    --remember-session \
    --asterisks \
    --greet-align center \
    --theme 'text=COLOR;time=COLOR;container=COLOR;border=COLOR;title=COLOR;greet=COLOR;prompt=COLOR;input=COLOR;action=COLOR;button=COLOR' \
    --cmd Hyprland"
user = "greeter"
```

Replace `COLOR` with any ANSI color name from the list above.

---

## Troubleshooting

### Colors don't look right
- VT (virtual terminal) has limited color support
- Some colors may appear differently than expected
- Try using basic colors (`red`, `blue`, `cyan`) instead of light variants

### Theme not applying
1. Check syntax - theme string must be in single quotes
2. Verify no typos in color names
3. Check `/etc/greetd/config.toml` was actually updated
4. Reboot to apply changes

### Want to match another terminal theme?
1. Extract color palette from your terminal config
2. Map colors to closest ANSI equivalents
3. Test and iterate!

---

## Color Mapping: Hex to ANSI

Can't use hex colors in tuigreet, but here's how to map them:

| Hex Range | ANSI Name |
|-----------|-----------|
| `#000000` - `#2e3440` | `black` |
| `#444444` - `#666666` | `darkgray` |
| `#888888` - `#aaaaaa` | `gray` |
| `#cccccc` - `#ffffff` | `white` or `lightgray` |
| Blue-ish (`#61afef`, `#528bff`) | `blue` or `lightblue` |
| Cyan-ish (`#9cdef2`, `#56b6c2`) | `cyan` or `lightcyan` |
| Red-ish (`#e06c75`) | `red` or `lightred` |
| Yellow-ish (`#e5c07b`) | `yellow` or `lightyellow` |
| Magenta-ish (`#c678dd`) | `magenta` or `lightmagenta` |

---

## Your Current Theme Breakdown

```bash
tuigreet \
    --time                    # Show clock
    --remember                # Remember username
    --remember-session        # Remember last session
    --asterisks               # Show *** for password
    --greet-align center      # Center greeting
    --theme '
        text=lightcyan;       # Main text: matches Alacritty foreground (#9cdef2)
        time=lightcyan;       # Clock: light cyan
        container=black;      # Background: dark (#282c34)
        border=blue;          # Borders: blue accent (#61afef)
        title=lightcyan;      # Titles: light cyan
        greet=lightcyan;      # Greeting: light cyan
        prompt=blue;          # "Username:"/"Password:": blue
        input=lightcyan;      # Your typed input: light cyan
        action=blue;          # Actions: blue
        button=cyan;          # Keybinds: cyan
    ' \
    --cmd Hyprland
```

**Result**: A unified Nord-inspired neon-accent theme from boot to desktop! 🚀
