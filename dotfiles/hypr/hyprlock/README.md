# hyprlock Configuration

GPU-accelerated screen locker for Hyprland with aesthetic matching your setup.

## What is hyprlock?

hyprlock is Hyprland's official screen locker - a modern, GPU-accelerated lock screen that integrates perfectly with Hyprland.

## Features

Our configuration includes:
- **Blurred wallpaper background**
- **Large time display** (light cyan #9cdef2)
- **Date display** (blue #61afef)
- **User greeting** (cyan #56b6c2)
- **Password input field** with blue border matching active windows
- **CAPS LOCK warning** (orange #fab387)
- **Visual feedback** when password is correct (cyan) or wrong (red)

## Color Scheme

Matches your Hyprland aesthetic:
- **Time**: Light cyan `#9cdef2`
- **Date/Border**: Blue `#61afef`
- **User/Check**: Cyan `#56b6c2`
- **Background**: Dark `#282c34`
- **Fail**: Red `#e06c75`
- **Warning**: Orange `#fab387`

## Files

- `hyprlock.conf` - Main hyprlock configuration
- `../scripts/capslock-status.sh` - Script to show CAPS LOCK warning

## Installation

```bash
# Install hyprlock
sudo pacman -S hyprlock

# Config is deployed via dotfiles symlink
# (deploy.sh handles this automatically)

# Test it
hyprlock

# Or bind to a key (already in hyprland.conf):
# Super + L = Lock screen
```

## Usage

### Lock Screen

```bash
# Lock manually
hyprlock

# Or use keybind:
Super + L
```

### Unlock

Type your user password and press Enter.

## Customization

Edit `hyprlock.conf` to change:

- **Background blur**: Adjust `blur_passes` and `blur_size`
- **Colors**: Change rgba values to match different themes
- **Time format**: Modify the `date` command format
- **Font**: Change `font_family` (currently using GohuFont)
- **Position**: Adjust `position` values for each element

## Auto-lock (Optional)

To automatically lock after inactivity:

```bash
# Install swayidle
sudo pacman -S swayidle

# Add to hyprland.conf:
exec-once = swayidle -w \
    timeout 300 'hyprlock' \
    timeout 600 'hyprctl dispatch dpms off' \
    resume 'hyprctl dispatch dpms on'
```

This will:
- Lock after 5 minutes of inactivity
- Turn off display after 10 minutes
- Wake up display on activity

## Troubleshooting

**hyprlock doesn't start:**
- Check it's installed: `which hyprlock`
- Try running manually: `hyprlock`
- Check logs: `journalctl -xe`

**Can't unlock:**
- Make sure you're using your USER password (not root)
- Check CAPS LOCK isn't on
- Try typing slowly

**Wallpaper not showing:**
- Verify wallpaper path in config: `~/.config/hypr/wallpapers/bg_wallpaper.png`
- Make sure file exists and is readable

**CAPS LOCK warning not showing:**
- Make sure capslock-status.sh is executable
- Check xset is installed: `pacman -Q xorg-xset`
