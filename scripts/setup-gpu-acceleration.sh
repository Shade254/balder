#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════
# GPU Hardware Acceleration Setup Script
# For Intel Graphics on T2 MacBook Pro (and other Macs with Intel GPUs)
# ═══════════════════════════════════════════════════════════════════════════
# This script installs and configures hardware video acceleration (VA-API)
# for Intel integrated graphics on Arch Linux / T2 MacBook systems
# ═══════════════════════════════════════════════════════════════════════════

set -e  # Exit on error

echo "═══════════════════════════════════════════════════════════════════════════"
echo "  GPU Hardware Acceleration Setup"
echo "  Intel Graphics - VA-API + Vulkan Configuration"
echo "═══════════════════════════════════════════════════════════════════════════"
echo ""

# ── STEP 1: Install Required Packages ─────────────────────────────────────
echo "[1/5] Installing hardware acceleration packages..."
echo ""

PACKAGES=(
    "intel-media-driver"    # VA-API driver (iHD) for Intel Gen 8+
    "libva-utils"           # VA-API testing tools (vainfo)
    "vulkan-tools"          # Vulkan testing (vulkaninfo)
)

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    pacman -S --needed --noconfirm "${PACKAGES[@]}"
else
    echo "Installing packages (requires sudo):"
    for pkg in "${PACKAGES[@]}"; do
        echo "  - $pkg"
    done
    sudo pacman -S --needed "${PACKAGES[@]}"
fi

echo "✓ Packages installed"
echo ""

# ── STEP 2: Create Chromium Flags Configuration ───────────────────────────
echo "[2/5] Creating Chromium flags configuration..."
echo ""

mkdir -p "$HOME/.config"
cat > "$HOME/.config/chromium-flags.conf" << 'EOF'
# ═══════════════════════════════════════════════════════════════════════════
# Chromium Hardware Acceleration Flags
# Intel Graphics - VA-API + Vulkan + Wayland
# ═══════════════════════════════════════════════════════════════════════════

# ── COMBINED FEATURE FLAGS (MUST BE SINGLE LINE!) ─────────────────────────
--enable-features=VaapiVideoDecoder,VaapiVideoEncoder,VaapiIgnoreDriverChecks,CanvasOopRasterization,UseSkiaRenderer
--disable-features=UseChromeOSDirectVideoDecoder

# ── GPU ACCELERATION ───────────────────────────────────────────────────────
--enable-gpu-rasterization
--enable-zero-copy
# NOTE: Vulkan disabled - incompatible with Wayland in Chromium
# --use-vulkan=native

# ── WAYLAND NATIVE SUPPORT ─────────────────────────────────────────────────
--ozone-platform=wayland
--enable-wayland-ime

# ── RENDERING OPTIMIZATIONS ────────────────────────────────────────────────
--enable-oop-rasterization
--canvas-oop-rasterization

# ── SMOOTH SCROLLING ───────────────────────────────────────────────────────
--enable-smooth-scrolling

# ── MEMORY & PERFORMANCE ───────────────────────────────────────────────────
--disk-cache-size=268435456
--enable-parallel-downloading
EOF

echo "✓ Created ~/.config/chromium-flags.conf"
echo ""

# ── STEP 3: Create Browser Launcher Scripts ───────────────────────────────
echo "[3/5] Creating browser launcher scripts..."
echo ""

mkdir -p "$HOME/.local/bin"

# BrowserOS launcher
cat > "$HOME/.local/bin/browseros" << 'EOF'
#!/bin/bash
# BrowserOS Hardware Acceleration Wrapper
export LIBVA_DRIVER_NAME=iHD
if [ -f "$HOME/.config/chromium-flags.conf" ]; then
    export CHROMIUM_FLAGS="$(cat ~/.config/chromium-flags.conf | grep -v '^#' | grep -v '^$' | tr '\n' ' ')"
fi
BROWSEROS_APPIMAGE="$HOME/.local/opt/browseros/BrowserOS.AppImage"
if [ -f "$BROWSEROS_APPIMAGE" ]; then
    exec "$BROWSEROS_APPIMAGE" $CHROMIUM_FLAGS "$@"
else
    echo "Error: BrowserOS not found at: $BROWSEROS_APPIMAGE"
    exit 1
fi
EOF

# Chromium launcher
cat > "$HOME/.local/bin/chromium-accel" << 'EOF'
#!/bin/bash
# Chromium Hardware Acceleration Wrapper
export LIBVA_DRIVER_NAME=iHD
export CHROMIUM_FLAGS="$(cat ~/.config/chromium-flags.conf | grep -v '^#' | grep -v '^$' | tr '\n' ' ')"
if command -v chromium &> /dev/null; then
    exec chromium $CHROMIUM_FLAGS "$@"
elif command -v chromium-browser &> /dev/null; then
    exec chromium-browser $CHROMIUM_FLAGS "$@"
else
    echo "Error: Chromium not found. Install with: sudo pacman -S chromium"
    exit 1
fi
EOF

# Chrome launcher
cat > "$HOME/.local/bin/chrome-accel" << 'EOF'
#!/bin/bash
# Chrome Hardware Acceleration Wrapper
export LIBVA_DRIVER_NAME=iHD
export CHROME_FLAGS="$(cat ~/.config/chromium-flags.conf | grep -v '^#' | grep -v '^$' | tr '\n' ' ')"
if command -v google-chrome-stable &> /dev/null; then
    exec google-chrome-stable $CHROME_FLAGS "$@"
elif command -v google-chrome &> /dev/null; then
    exec google-chrome $CHROME_FLAGS "$@"
else
    echo "Error: Chrome not found. Install from AUR: yay -S google-chrome"
    exit 1
fi
EOF

# Brave launcher
cat > "$HOME/.local/bin/brave-accel" << 'EOF'
#!/bin/bash
# Brave Hardware Acceleration Wrapper
export LIBVA_DRIVER_NAME=iHD
export BRAVE_FLAGS="$(cat ~/.config/chromium-flags.conf | grep -v '^#' | grep -v '^$' | tr '\n' ' ')"
if command -v brave &> /dev/null; then
    exec brave $BRAVE_FLAGS "$@"
elif command -v brave-browser &> /dev/null; then
    exec brave-browser $BRAVE_FLAGS "$@"
else
    echo "Error: Brave not found. Install with: sudo pacman -S brave-bin"
    exit 1
fi
EOF

chmod +x "$HOME/.local/bin/browseros"
chmod +x "$HOME/.local/bin/chromium-accel"
chmod +x "$HOME/.local/bin/chrome-accel"
chmod +x "$HOME/.local/bin/brave-accel"

echo "✓ Created browser launcher scripts in ~/.local/bin/"
echo ""

# ── STEP 4: Update Shell Configuration ────────────────────────────────────
echo "[4/5] Checking shell configuration..."
echo ""

ZSHRC="$HOME/.zshrc"
if [ -f "$HOME/balder/dotfiles/zsh/.zshrc" ]; then
    ZSHRC="$HOME/balder/dotfiles/zsh/.zshrc"
fi

# Check if GPU acceleration section exists
if ! grep -q "# GPU Hardware Acceleration" "$ZSHRC"; then
    echo "Adding GPU acceleration environment variables to $ZSHRC..."

    # Find the PATH export line and add GPU config after it
    if grep -q 'export PATH.*local/bin' "$ZSHRC"; then
        # Add after PATH export
        sed -i '/export PATH.*local\/bin/a \
\
# ==================\
# GPU Hardware Acceleration\
# ==================\
# Intel Graphics - VA-API & Vulkan acceleration\
export LIBVA_DRIVER_NAME=iHD              # Use intel-media-driver (modern iHD, not legacy i965)\
\
# Firefox optimizations\
export MOZ_DISABLE_RDD_SANDBOX=1          # Allow Firefox GPU access for hardware decode\
export MOZ_USE_XINPUT2=1                  # Smooth scrolling in Firefox\
export MOZ_ENABLE_WAYLAND=1               # Wayland support\
\
# Chromium/Chrome optimizations\
export CHROMIUM_FLAGS="--enable-features=VaapiVideoDecoder,VaapiVideoEncoder --enable-gpu-rasterization --enable-zero-copy --use-vulkan=native"' "$ZSHRC"
        echo "✓ Added GPU acceleration config to $ZSHRC"
    else
        echo "⚠ Could not find PATH export in $ZSHRC"
        echo "  Please manually add GPU acceleration variables to your shell config"
    fi
else
    echo "✓ GPU acceleration config already exists in $ZSHRC"
fi

echo ""

# ── STEP 5: Verify Installation ───────────────────────────────────────────
echo "[5/5] Verifying installation..."
echo ""

# Test VA-API
echo "Testing VA-API driver..."
if LIBVA_DRIVER_NAME=iHD vainfo 2>&1 | grep -q "Intel iHD driver"; then
    echo "✓ VA-API (iHD driver) is working"
else
    echo "⚠ VA-API test failed - may need reboot"
fi

# Test Vulkan
echo "Testing Vulkan..."
if vulkaninfo --summary 2>&1 | grep -q "Intel"; then
    echo "✓ Vulkan is working"
else
    echo "⚠ Vulkan test failed - may need reboot"
fi

echo ""
echo "═══════════════════════════════════════════════════════════════════════════"
echo "  ✅ GPU Hardware Acceleration Setup Complete!"
echo "═══════════════════════════════════════════════════════════════════════════"
echo ""
echo "Next steps:"
echo "  1. Restart your terminal or run: source ~/.zshrc"
echo "  2. Launch BrowserOS with: browseros"
echo "  3. Verify acceleration at: chrome://gpu"
echo "  4. Test with YouTube video - CPU should stay low (5-15%)"
echo ""
echo "For other browsers:"
echo "  - Chromium:  chromium-accel"
echo "  - Chrome:    chrome-accel"
echo "  - Brave:     brave-accel"
echo ""
echo "Documentation: ~/balder/docs/GPU_ACCELERATION_SETUP.md"
echo "═══════════════════════════════════════════════════════════════════════════"
