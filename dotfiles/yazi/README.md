# Yazi File Manager Configuration

Blazing-fast terminal file manager written in Rust with image preview support.

## Quick Reference

Launch: `CMD+E` (Super+E) from anywhere in Hyprland

### Keybindings

| Key | Action |
|-----|--------|
| `i` | Toggle hidden files |
| `/` | Search files (via fd) |
| `e` | Open file with default app |
| `b` | Toggle preview pane |
| `c` | Open in Cursor |
| `n` | Edit with nano |
| `w` | Copy file path to clipboard |
| `f` | Copy filename to clipboard |
| `o` | Open Thunar file manager here |

### Navigation

| Key | Action |
|-----|--------|
| `j/k` | Move down/up |
| `h/l` | Parent dir / Enter dir |
| `gg` | Go to top |
| `G` | Go to bottom |
| `~` | Go to home |

### File Operations

| Key | Action |
|-----|--------|
| `y` | Yank (copy) |
| `d` | Cut |
| `p` | Paste |
| `r` | Rename |
| `a` | Create file |
| `A` | Create directory |
| `x` | Delete |

## Files

- `yazi.toml` - Main configuration (layout, openers, file associations)
- `keymap.toml` - Custom keybindings
- `theme.toml` - Nord-inspired neon theme
- `package.toml` - Plugin dependencies

## Theme

Nord-inspired color scheme matching Alacritty:
- Light cyan (`#9cdef2`) - Primary accent
- Blue (`#61afef`) - Directories & UI
- Dark background (`#282c34`)

## Image Preview

Uses Chafa with Sixel protocol via `alacritty-sixel-git` for pixel-perfect image previews that follow the preview pane automatically.

## Plugins

- **toggle-pane** - Toggle preview pane visibility with `b`

## Dependencies

```bash
# Core
pacman -S yazi fd ripgrep

# Image preview (Sixel support)
yay -S alacritty-sixel-git chafa

# File openers
pacman -S imv vlc zathura file-roller thunar
```

## Links

- [Yazi Documentation](https://yazi-rs.github.io/docs)
- [Yazi Plugins](https://yazi-rs.github.io/docs/resources#plugins)
