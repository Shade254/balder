# Speech-to-Text Input Simulation Research for Hyprland

**Research Date**: 2025-11-11
**Target Platform**: Wayland/Hyprland on Arch Linux
**Use Case**: Programmatic text injection from speech-to-text into any focused application

---

## Executive Summary

This research identifies viable tools and approaches for building a speech-to-text system that can inject transcribed text into any focused window on Hyprland. The recommended approach uses **dotool** or **wtype** for input simulation, **PipeWire/pw-record** for audio capture, and **whisper.cpp** for offline speech recognition.

---

## 1. Input Simulation Tools for Wayland/Hyprland

### 1.1 **wtype** (RECOMMENDED for simplicity)

**Status**: Available in Arch repos (`extra/wtype 0.4-2`)

**Description**: xdotool type for Wayland - simple keyboard text input via virtual-keyboard protocol

**Pros**:
- Simple command-line syntax
- Uses Wayland virtual-keyboard protocol (native to compositor)
- Lightweight with no daemon required
- Works well with Hyprland (wlroots-based)
- Fast text injection
- No root/special permissions needed

**Cons**:
- Keyboard-only (no mouse simulation)
- Cannot target specific windows
- Known issue: May not work when triggered directly from Hyprland keybindings (workaround available)
- Does not work with XWayland applications

**Installation**:
```bash
sudo pacman -S wtype
```

**Usage Examples**:
```bash
# Type text
wtype "Hello World"

# Type with delay between keystrokes
wtype -s 50 "Slower typing"  # 50ms delay

# Press keys
wtype -P shift -P a -p shift -p a  # Types "A"

# Press modifier combinations
wtype -M ctrl -M shift t  # Ctrl+Shift+T
```

**Integration with Hyprland Keybinding**:
```
# In hyprland.conf - wrap in script to avoid keybind timing issues
bind = SUPER, M, exec, ~/.config/hypr/scripts/speech-to-text.sh
```

---

### 1.2 **dotool** (RECOMMENDED for robustness)

**Status**: Available in AUR

**Description**: Command to simulate input anywhere (X11, Wayland, TTYs) using Linux uinput

**Pros**:
- No root permissions required (on most distros)
- No daemon needed (unlike ydotool)
- Works in X11, Wayland, and TTYs
- Supports keyboard AND mouse simulation
- More reliable than ydotool
- Independent of display server
- Works with all applications including XWayland

**Cons**:
- Non-standard stdin-based syntax
- May require user to be in 'input' group on some distros
- Less intuitive command structure

**Installation**:
```bash
yay -S dotool  # AUR package
# OR build from source: https://sr.ht/~geb/dotool/
```

**Setup**:
```bash
# Check if you need to add user to input group
groups $USER | grep -q input || sudo usermod -a -G input $USER
# May require logout/login to apply
```

**Usage Examples**:
```bash
# Type text
echo type "Hello World" | dotool

# Press key combinations
echo key ctrl+w | dotool

# Complex sequences
{
  echo type "First line"
  echo key enter
  echo type "Second line"
} | dotool

# Mouse operations
echo mouseto 0.5 0.5 | dotool    # Move to center (50%, 50%)
echo click left | dotool
```

**Delays**:
```bash
echo typedelay 50 | dotool    # 50ms between characters
echo keyhold 100 | dotool     # Hold keys for 100ms
```

---

### 1.3 **ydotool**

**Status**: Available in Arch repos (`extra/ydotool 1.0.4-2`)

**Description**: Generic automation tool using uinput (works without X11)

**Pros**:
- Works on X11, Wayland, and TTYs
- Supports keyboard and mouse
- More features than wtype

**Cons**:
- Requires running a daemon (`ydotoold`)
- Typically needs root/elevated permissions for `/dev/uinput`
- Slower than direct API/DBus options
- Officially ignores non-ASCII characters
- Complex permission setup
- Less reliable than alternatives
- Version in repos may have bugs

**NOT RECOMMENDED** due to daemon requirement and permission complexity.

---

### 1.4 Comparison Matrix

| Feature | wtype | dotool | ydotool |
|---------|-------|--------|---------|
| **Installation** | Official repo | AUR | Official repo |
| **Permissions** | None | input group (maybe) | Root/setup required |
| **Daemon** | No | No | Yes (ydotoold) |
| **Syntax** | CLI args | stdin | CLI args |
| **Mouse support** | No | Yes | Yes |
| **XWayland apps** | No | Yes | Yes |
| **Speed** | Fast | Fast | Slower |
| **Reliability** | Good | Very Good | Fair |
| **Complexity** | Low | Medium | High |

**Recommendation**:
- Use **wtype** for quick text-only injection with native Wayland apps
- Use **dotool** for production systems requiring XWayland support and reliability

---

## 2. Wayland Security Model & Permissions

### 2.1 Security Architecture

Wayland implements a fundamentally different security model than X11:

- **Isolated clients**: Each client runs in its own sandbox
- **Compositor-mediated**: Only the compositor knows what's happening across sessions
- **No shared event queue**: Applications cannot spy on each other's input
- **No silent input grabs**: Applications cannot steal input from other windows
- **Permission-based**: Privileged operations require explicit permissions

### 2.2 Virtual Keyboard Protocol

Input simulation tools use the **virtual-keyboard-unstable-v1** protocol:

- Implemented by wlroots (used by Hyprland)
- Allows emulating physical keyboard behavior
- Provides raw input events to the compositor
- Can be used standalone or with input-method protocol

**Protocol capabilities** (via Wayland Security Module):
- `WSM_VIRTUAL_KEYBOARD`: Inject or filter keyboard input (default: soft-deny)
- `WSM_VIRTUAL_POINTING`: Modify pointer position and clicks (default: soft-deny)

### 2.3 Permission Management

**Tools using virtual-keyboard protocol** (wtype, dotool via uinput):
- wtype: No special permissions (uses compositor's virtual-keyboard protocol)
- dotool: May require `input` group membership for uinput access

**Check current permissions**:
```bash
# Check user groups
groups $USER

# Check uinput permissions
ls -l /dev/uinput

# Add to input group if needed (dotool)
sudo usermod -a -G input $USER
```

**Current user status**: `miro : miro wheel video nordvpn`
- Already in `wheel` group (sudo access)
- May need `input` group for dotool if not auto-configured

### 2.4 Security Implications

Wayland's security model prevents:
- Keyloggers reading arbitrary application input
- Fake input injection to elevated applications
- Screen content reading by unprivileged apps

**For speech-to-text**, this means:
- Input simulation works for normal user applications
- Cannot inject into sudo prompts or privileged contexts
- Safer than X11 (where any app can read/inject everywhere)

---

## 3. Audio Capture with PipeWire

### 3.1 PipeWire Overview

PipeWire is the modern Linux audio/video server (replacement for PulseAudio):

**Status**: Already installed (`/usr/bin/pw-record` found)

**Benefits**:
- Low latency
- Professional audio routing
- PulseAudio compatibility layer
- Better resource management than PulseAudio

### 3.2 Recording Commands

**pw-record** (primary tool):
```bash
# Basic recording
pw-record output.wav

# With options
pw-record --latency=20ms --volume=1.0 --format=s16 --rate=16000 output.wav

# Target specific microphone
pw-record --target alsa_input.usb-Device_Name.mono output.wav
```

**Finding input devices**:
```bash
# List audio sources (PulseAudio compatibility)
pactl list sources

# JSON format with filtering
pactl --format=json list sources | jq '.[] | select(.monitor_source == "") | {name: .name, desc: .description}'

# PipeWire native tools
pw-cli list-objects Node
```

**Stop recording**:
- Press `Ctrl+C` to stop recording
- Or use process management to kill pw-record

### 3.3 Alternative: arecord (ALSA)

```bash
# With PipeWire
arecord -D pipewire -c1 -fS16_LE -r16000 -twav output.wav

# Direct hardware
arecord --duration=5 --format=dat --device=hw:0,0 test-mic.wav
```

### 3.4 Push-to-Talk Implementation

**Approach 1: Hold-to-record (recommended)**
```bash
#!/bin/bash
# Start recording when script runs
pw-record /tmp/speech-input-$$.wav &
RECORD_PID=$!

# Wait for user to release key (handled by keybind)
# Then kill recording
kill -INT $RECORD_PID
```

**Approach 2: Toggle recording**
```bash
#!/bin/bash
PIDFILE=/tmp/speech-recording.pid

if [ -f "$PIDFILE" ]; then
    # Stop recording
    kill -INT $(cat "$PIDFILE")
    rm "$PIDFILE"
else
    # Start recording
    pw-record /tmp/speech-input.wav &
    echo $! > "$PIDFILE"
fi
```

**Approach 3: Using pactl for muting (not recording)**
```bash
# Mute/unmute microphone (for privacy, not recording)
pactl set-source-mute @DEFAULT_SOURCE@ toggle
```

### 3.5 Audio Format Recommendations

For speech recognition:

- **Sample rate**: 16000 Hz (16 kHz) - optimal for speech
- **Format**: 16-bit PCM (s16le)
- **Channels**: Mono (1 channel)
- **Codec**: WAV (uncompressed for processing)

**Example optimal settings**:
```bash
pw-record --rate=16000 --format=s16 --channels=1 output.wav
```

---

## 4. Speech Recognition Solutions - Comprehensive Comparison

### 4.1 Solution Overview

This section compares all viable speech-to-text solutions for Arch Linux, from ready-made applications to DIY implementations.

| Solution | Architecture | Installation | Latency | Privacy | Wayland Support | Complexity |
|----------|-------------|--------------|---------|---------|-----------------|------------|
| **nerd-dictation** | Local (VOSK) | Low | 100-200ms | Excellent | Full (dotool/ydotool/wtype) | Low |
| **faster-whisper-dictation** | Local (Whisper) | Low-Medium | 200-500ms (CPU)<br><100ms (GPU) | Excellent | Good (ydotool) | Low |
| **whisper.cpp + voice_typing** | Local/Hybrid | Medium | 100-300ms | Excellent | Full (ydotool) | Medium |
| **Whisper-Dictation** | Local (Whisper) | Low | 200-400ms | Excellent | Limited (KDE focused) | Medium |
| **HyprVoice** | Local (Whisper) | Low | 1-2s | Excellent | Full (wtype) | Low |
| **OpenAI Whisper API** | Cloud | Low | 500-1000ms | Poor | Good (via ydotool) | Medium |
| **Wispr Flow** | Cloud | N/A | Very Low | Poor | Not supported | N/A |

---

### 4.2 nerd-dictation (VOSK-based) - BEST FOR SIMPLICITY

**Architecture**: Fully local, uses VOSK speech recognition engine

**Repository**: https://github.com/ideasman42/nerd-dictation

**Pros**:
- Excellent Wayland/Hyprland support via dotool, ydotool, or wtype
- Simple Python-based tool, easy to understand and modify
- Fast processing (10x per second by default)
- 100% offline and privacy-respecting
- Multiple language model sizes available
- Works in TTYs, X11, and Wayland
- Proven track record

**Cons**:
- VOSK accuracy lower than Whisper models
- ALL TEXT LOWERCASE by default (requires user config for capitalization)
- Initial load time can be slow with larger models
- Less sophisticated than modern transformer models

**Installation** (Arch Linux):
```bash
# Install dependencies
pip3 install vosk

# Install ydotool or dotool for Wayland text input
yay -S ydotool  # or dotool from AUR

# Clone and setup
git clone https://github.com/ideasman42/nerd-dictation.git
cd nerd-dictation
wget https://alphacephei.com/kaldi/models/vosk-model-small-en-us-0.15.zip
unzip vosk-model-small-en-us-0.15.zip
mv vosk-model-small-en-us-0.15 model
```

**Hyprland Integration**:
```conf
# ~/.config/hypr/hyprland.conf
bind = SUPER, M, exec, /path/to/nerd-dictation/nerd-dictation begin --simulate-input-tool=DOTOOL
bind = SUPER_SHIFT, M, exec, /path/to/nerd-dictation/nerd-dictation end
```

**Best For**: Users prioritizing privacy, simplicity, and proven Wayland compatibility

---

### 4.3 faster-whisper-dictation - ⭐ RECOMMENDED FOR BEST ACCURACY

**Architecture**: Local Whisper using CTranslate2 optimization

**Repository**: https://github.com/theRealCarneiro/faster-whisper-dictation

**Pros**:
- Uses state-of-the-art Whisper models (better accuracy than VOSK)
- 4x faster than original Whisper implementation
- Persistent daemon avoids model reload delays
- Simple keyboard shortcut activation (double-tap right-super by default)
- 100% offline processing
- GPU acceleration support (CUDA, ROCm)
- Lower memory usage than original Whisper
- Proper capitalization and punctuation

**Cons**:
- Wayland compatibility not explicitly documented (likely works with ydotool)
- Higher resource requirements than VOSK
- Requires Python environment

**Installation** (Arch Linux):
```bash
# Install dependencies
yay -S portaudio python-pip ydotool

# Install faster-whisper-dictation
pip install faster-whisper-dictation

# For GPU support (optional)
pip install faster-whisper[gpu]
```

**Usage**:
```bash
# Start daemon with custom hotkey
faster-whisper-dictation --key-combo "<super>+<shift>+m"

# Or use default (double-tap right-super)
faster-whisper-dictation
```

**Best For**: Users wanting best-in-class accuracy with local processing and optional GPU acceleration

---

### 4.4 whisper.cpp + voice_typing - BEST FOR PERFORMANCE

**Architecture**: Local C++ Whisper implementation with optional network server

**Repository**:
- whisper.cpp: https://github.com/ggml-org/whisper.cpp
- voice_typing: https://github.com/themanyone/voice_typing

**Pros**:
- Fastest CPU implementation of Whisper (6-7x faster than original)
- Can run as network server for shared GPU resources
- Works with X11, Wayland, and TTYs via ydotool
- Minimal resource consumption
- Extremely hackable bash-based implementation
- Supports remote Whisper.cpp server for distributed processing

**Cons**:
- Requires compiling whisper.cpp from source or AUR package
- More complex setup than Python alternatives
- Bash scripting knowledge helpful for customization
- Multiple components to configure

**Installation** (Arch Linux):
```bash
# Install whisper.cpp from AUR
yay -S whisper.cpp

# Install voice_typing
git clone https://github.com/themanyone/voice_typing.git
cd voice_typing
# Review and customize the bash script

# Install dependencies
yay -S ydotool sox
```

**Hyprland Integration**:
```bash
# Create wrapper script for keyboard shortcut
# Then bind in hyprland.conf
bind = SUPER, M, exec, /path/to/voice_typing/start-dictation.sh
```

**Best For**: Technical users wanting maximum performance on CPU, or hybrid local/remote setup

---

### 4.5 whisper.cpp (Standalone) - ORIGINAL RECOMMENDATION

**Description**: High-performance C++ port of OpenAI's Whisper ASR model

**Status**: Available in AUR

**Pros**:
- Completely offline (no API costs, no data sharing)
- Excellent accuracy
- Multiple model sizes (tiny to large)
- CPU-only inference (works without GPU)
- Low memory usage
- Automatic language detection
- Fast inference with optimizations (AVX, quantization)
- Cross-platform (Linux, macOS, Windows)

**Cons**:
- Requires model download (39 MB for tiny, 1.5 GB for large)
- Initial transcription latency (1-3 seconds depending on model)
- Requires custom script integration (not ready-to-use)
- Requires build dependencies

**Installation**:
```bash
# Install from AUR
yay -S whisper.cpp

# OR build from source
git clone https://github.com/ggml-org/whisper.cpp
cd whisper.cpp
make

# Download models
bash ./models/download-ggml-model.sh base  # 142 MB, good balance
# Or: tiny (39MB), small (466MB), medium (1.5GB), large (2.9GB)
```

**Usage**:
```bash
# Basic transcription
./main -m models/ggml-base.en.bin -f input.wav

# With options
./main -m models/ggml-base.en.bin -f input.wav --language en --threads 4

# Output just text (no timestamps)
./main -m models/ggml-base.en.bin -f input.wav --no-timestamps --print-special false
```

**Model recommendations**:
- **tiny** (39 MB): Fast but less accurate - good for testing
- **base** (142 MB): **RECOMMENDED** - good balance of speed and accuracy
- **small** (466 MB): Better accuracy, acceptable speed
- **medium/large**: Best accuracy but slower

**Distilled variants**: 6x faster with similar accuracy - excellent for real-time use.

---

### 4.6 Cloud APIs (NOT RECOMMENDED)

**OpenAI Whisper API**:
```bash
# Requires API key and internet
curl -X POST https://api.openai.com/v1/audio/transcriptions \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -F file=@input.wav -F model=whisper-1
```

**Pros**: Most accurate, no local compute
**Cons**:
- Costs money ($0.006/minute = $0.36/hour)
- Requires internet connection
- Privacy concerns (audio sent to OpenAI)
- 500-1000ms latency

**Google Speech-to-Text**: Similar pros/cons

**NOT RECOMMENDED** for privacy and cost reasons when local solutions work well.

---

### 4.7 Wispr Flow - NOT AVAILABLE

**Status**: macOS, Windows, and iOS only - **NO LINUX SUPPORT**

Wispr Flow currently has no Linux version. Users can register interest for future development, but it's not available as of November 2025.

---

### 4.8 Recommended Choice Matrix

**Choose based on your priority:**

| Priority | Recommended Solution | Why |
|----------|---------------------|-----|
| **Best Accuracy** | faster-whisper-dictation | State-of-the-art Whisper with optimization |
| **Easiest Setup** | nerd-dictation or HyprVoice | Simple install, proven compatibility |
| **Best Performance** | whisper.cpp + voice_typing | Fastest CPU implementation |
| **Ready-to-Use** | HyprVoice | Complete daemon-based solution |
| **Maximum Privacy** | Any local solution | All local options are 100% offline |
| **Lowest Latency** | nerd-dictation (VOSK) | 100-200ms processing time |

**Overall Recommendation**: **faster-whisper-dictation** for the best balance of accuracy, performance, and ease of use.

---

## 5. Existing Reference Implementations

### 5.1 HyprVoice

**Repository**: https://github.com/LeonardoTrapani/hyprvoice

**Description**: Complete voice-powered typing for Wayland/Hyprland

**Tech Stack**:
- Go application
- PipeWire for audio
- wtype for text injection
- Desktop notifications for feedback
- Systemd service

**Features**:
- Daemon architecture
- Real-time feedback
- Multiple transcription backends (Whisper, OpenAI)
- Clipboard save/restore
- Direct typing with fallback

**Status**: Beta but functional

**Installation**: Available in AUR (`hyprvoice-bin`)

**Usage**:
1. Install and start service: `systemctl --user start hyprvoice`
2. Bind keyboard shortcut in hyprland.conf
3. Press key to start recording
4. Release to transcribe and inject

**Pros**: Ready-to-use solution, well-integrated
**Cons**: Beta status, may need customization

### 5.2 waystt

**Repository**: https://github.com/sevos/waystt

**Description**: Minimal signal-driven speech-to-text for Wayland

**Features**:
- Signal-based activation
- PipeWire audio capture
- Whisper or Google Speech-to-Text
- Automatic language detection (Whisper)

**Pros**: Minimal design, flexible
**Cons**: Requires more setup

### 5.3 whisper-overlay

**Repository**: https://github.com/oddlama/whisper-overlay

**Description**: Wayland overlay with global push-to-talk hotkey

**Features**:
- Global hotkey (hold to record)
- Real-time transcription overlay
- Visual feedback during recording

**Pros**: Push-to-talk interface, visual feedback
**Cons**: More complex setup

### 5.4 BlahST

**Repository**: https://github.com/QuantiusBenignus/BlahST

**Description**: Offline speech-to-text using whisper.cpp for any Linux window

**Features**:
- Uses whisper.cpp locally
- Offline operation
- Can speak with local LLMs (llama.cpp integration)

---

## 6. Recommended Workflow Architecture

### 6.1 System Architecture

```
[User presses keybind]
        |
        v
[Hyprland detects key] --> [Execute script]
        |
        v
[Start audio recording] --> [PipeWire/pw-record]
        |
        v
[Wait for key release or timeout]
        |
        v
[Stop recording] --> [Save to /tmp/speech-XXXX.wav]
        |
        v
[Process audio] --> [whisper.cpp transcription]
        |
        v
[Get transcribed text]
        |
        v
[Inject text] --> [wtype or dotool]
        |
        v
[Clean up temp file]
```

### 6.2 Implementation Approaches

**Option A: Hold-to-Record (Recommended)**
```
User holds SUPER+M
  --> Recording starts
  --> Shows notification "Recording..."
  --> User speaks
User releases SUPER+M
  --> Recording stops
  --> Transcription begins
  --> Text injected
  --> Shows notification "Injected: [text]"
```

**Option B: Press-to-Toggle**
```
User presses SUPER+M once
  --> Recording starts
  --> Shows notification "Recording... (press again to stop)"
User presses SUPER+M again
  --> Recording stops
  --> Rest same as Option A
```

**Option C: Daemon-based (Like HyprVoice)**
```
Background daemon listens for signals
User triggers via keybind
  --> Sends signal to daemon
  --> Daemon handles recording/transcription
  --> Daemon injects text
```

### 6.3 Recommended Technology Stack

**For simple implementation**:
- Input: **wtype** (simple, lightweight)
- Audio: **pw-record** (already available)
- Recognition: **whisper.cpp base model** (good balance)
- Trigger: Hyprland keybind + shell script

**For robust implementation**:
- Input: **dotool** (XWayland support, more reliable)
- Audio: **pw-record** with explicit device selection
- Recognition: **whisper.cpp base or small model**
- Trigger: Systemd service + keybind (daemon approach)
- Feedback: **notify-send** for desktop notifications

---

## 7. Required Packages

### 7.1 Core Packages

```bash
# Input simulation (choose one)
sudo pacman -S wtype              # Simple, recommended for start
yay -S dotool                     # Robust, recommended for production

# Audio capture (already installed)
# pw-record is part of pipewire package

# Speech recognition
yay -S whisper.cpp                # Offline recognition
# OR build from source (see section 4.1)

# Optional utilities
sudo pacman -S libnotify          # For notify-send (desktop notifications)
sudo pacman -S jq                 # JSON parsing for device detection
```

### 7.2 Alternative: Use HyprVoice

```bash
yay -S hyprvoice-bin
systemctl --user enable --now hyprvoice
```

Then add to `/home/miro/balder/dotfiles/hypr/hyprland.conf`:
```
bind = SUPER, M, exec, hyprvoicectl start-recording
```

---

## 8. Sample Implementation Script

### 8.1 Basic Shell Script (Hold-to-Record)

```bash
#!/bin/bash
# ~/.config/hypr/scripts/speech-to-text.sh

# Configuration
WHISPER_MODEL="$HOME/.local/share/whisper.cpp/models/ggml-base.en.bin"
WHISPER_BIN="$HOME/.local/bin/whisper.cpp/main"
TEMP_AUDIO="/tmp/speech-input-$$.wav"
RECORDING_PID_FILE="/tmp/speech-recording-$$.pid"

# Start recording
notify-send "Speech-to-Text" "Recording..." -t 1000
pw-record --rate=16000 --format=s16 --channels=1 "$TEMP_AUDIO" &
RECORD_PID=$!
echo $RECORD_PID > "$RECORDING_PID_FILE"

# Wait for key release (handled by Hyprland keybind release)
# For hold-to-record, this script would be called twice:
# - Once on key press (start recording)
# - Once on key release (stop recording)

# For simplicity, use timeout
sleep 10  # Max recording time

# Stop recording
kill -INT $RECORD_PID 2>/dev/null
wait $RECORD_PID 2>/dev/null
rm -f "$RECORDING_PID_FILE"

# Check if audio file exists and has content
if [ ! -s "$TEMP_AUDIO" ]; then
    notify-send "Speech-to-Text" "No audio recorded" -u critical
    exit 1
fi

# Transcribe
notify-send "Speech-to-Text" "Transcribing..." -t 2000
TRANSCRIPTION=$("$WHISPER_BIN" -m "$WHISPER_MODEL" -f "$TEMP_AUDIO" --no-timestamps --print-special false 2>/dev/null | grep -v '^\[' | sed 's/^[[:space:]]*//')

# Clean up
rm -f "$TEMP_AUDIO"

# Check if transcription succeeded
if [ -z "$TRANSCRIPTION" ]; then
    notify-send "Speech-to-Text" "Transcription failed" -u critical
    exit 1
fi

# Inject text
wtype "$TRANSCRIPTION"

# Notify user
notify-send "Speech-to-Text" "Injected: $TRANSCRIPTION" -t 3000
```

### 8.2 Hyprland Configuration

Add to `/home/miro/balder/dotfiles/hypr/hyprland.conf`:

```
# Speech-to-text (SUPER+M)
bind = SUPER, M, exec, ~/.config/hypr/scripts/speech-to-text.sh
```

### 8.3 Advanced: Hold-to-Record Implementation

Requires two separate scripts and bind/release keybinds (may need custom implementation or use HyprVoice).

---

## 9. Testing & Validation Checklist

### 9.1 Initial Setup Testing

- [ ] Install input tool (wtype or dotool)
- [ ] Verify pw-record works: `pw-record test.wav` (Ctrl+C to stop)
- [ ] List audio devices: `pactl list sources`
- [ ] Install whisper.cpp and download base model
- [ ] Test whisper.cpp: Record sample, transcribe manually
- [ ] Test input injection: `wtype "test"` in terminal
- [ ] Verify user permissions (groups, /dev/uinput)

### 9.2 Integration Testing

- [ ] Create script in `~/.config/hypr/scripts/`
- [ ] Make script executable: `chmod +x speech-to-text.sh`
- [ ] Test script manually: `./speech-to-text.sh`
- [ ] Add keybind to hyprland.conf
- [ ] Reload Hyprland: `hyprctl reload`
- [ ] Test keybind in different applications:
  - [ ] Terminal (Alacritty)
  - [ ] Browser (Firefox)
  - [ ] Text editor (Cursor, VSCode)
  - [ ] Native Wayland app
  - [ ] XWayland app (if using dotool)

### 9.3 Quality Validation

- [ ] Test accuracy with clear speech
- [ ] Test with background noise
- [ ] Test with different speaking speeds
- [ ] Test punctuation handling
- [ ] Measure latency (recording → injection)
- [ ] Test special characters
- [ ] Test multi-language (if needed)

### 9.4 Edge Cases

- [ ] Empty recording (no speech)
- [ ] Long recording (>30 seconds)
- [ ] Fast consecutive activations
- [ ] Activation while another app has focus
- [ ] Activation in locked screen
- [ ] Microphone not available

---

## 10. Performance Optimization

### 10.1 Latency Optimization

**Audio capture**:
- Use `--latency=20ms` flag for pw-record
- Use 16kHz sample rate (optimal for speech)

**Transcription**:
- Use quantized models (faster inference)
- Enable CPU optimizations (AVX2, FMA)
- Use appropriate model size:
  - **tiny**: ~0.5-1s latency
  - **base**: ~1-2s latency
  - **small**: ~2-4s latency

**Text injection**:
- wtype is already fast
- Reduce typing delay if using dotool: `echo typedelay 0 | dotool`

### 10.2 Resource Usage

**whisper.cpp CPU usage**:
- tiny: ~30-50% single core
- base: ~50-70% single core
- small: ~70-90% single core

**Memory usage**:
- tiny: ~75 MB
- base: ~150 MB
- small: ~500 MB

### 10.3 Battery Impact

For MacBook T2 (battery-conscious):
- Use **base** model (good balance)
- Consider caching frequent phrases
- Implement timeout to prevent long recordings

---

## 11. Privacy & Security Considerations

### 11.1 Privacy Benefits

**Using offline solution (whisper.cpp)**:
- No audio sent to cloud
- No API keys or accounts needed
- No logging by third parties
- Complete control over data

### 11.2 Security Considerations

**Wayland security model**:
- Input injection works for user-level apps
- Cannot inject into elevated prompts (sudo, polkit)
- Cannot inject into lock screen
- Safer than X11 architecture

**Recommendations**:
- Store temporary audio in `/tmp` (memory-backed on many systems)
- Clean up audio files immediately after transcription
- Avoid storing transcriptions unless needed
- Be aware of what applications are focused when injecting

### 11.3 Sensitive Contexts

**Avoid using speech-to-text for**:
- Password inputs
- Sensitive commands (rm -rf, sudo)
- Private information

**Safety features to implement**:
- Notification before injection (so user can cancel)
- Configurable blacklist of applications
- Visual indicator during recording

---

## 12. Future Enhancements

### 12.1 Potential Improvements

- **Real-time streaming**: Start transcribing while still recording
- **Custom vocabulary**: Train on technical terms, names
- **Command mode**: Special phrases trigger commands instead of text
- **Multi-language**: Auto-detect and switch languages
- **Punctuation commands**: Say "period" to insert "."
- **Correction mode**: Re-record last phrase
- **History**: Save transcription history with undo

### 12.2 Advanced Features

- **Integration with clipboard**: Option to copy instead of type
- **Templates**: Predefined phrases for common text
- **Context awareness**: Different behavior based on focused app
- **Voice commands**: "new line", "delete last word", etc.
- **Continuous mode**: Always listening in background

---

## 13. Troubleshooting

### 13.1 Common Issues

**Issue**: wtype doesn't work from Hyprland keybind
**Solution**: Wrap in shell script with small delay: `sleep 0.1; wtype "$TEXT"`

**Issue**: No audio captured
**Solution**: Check default input device: `pactl get-default-source`

**Issue**: Transcription returns empty
**Solution**: Check model path, verify audio file has content

**Issue**: Text injected multiple times
**Solution**: Ensure script isn't being called multiple times, check for key repeat

**Issue**: Special characters not working
**Solution**: Use dotool instead of wtype for better Unicode support

**Issue**: High CPU usage
**Solution**: Use smaller whisper model (base instead of small/medium)

### 13.2 Debugging

**Enable verbose logging**:
```bash
# Add to script
set -x  # Enable bash debug output
export WHISPER_DEBUG=1
```

**Check audio file**:
```bash
# Verify audio was recorded
ls -lh /tmp/speech-input-*.wav
# Play back to verify content
ffplay /tmp/speech-input-*.wav
```

**Test whisper.cpp directly**:
```bash
./main -m model.bin -f input.wav --print-colors
```

---

## 14. References & Resources

### 14.1 Official Documentation

- **wtype**: https://github.com/atx/wtype
- **dotool**: https://sr.ht/~geb/dotool/
- **whisper.cpp**: https://github.com/ggml-org/whisper.cpp
- **PipeWire**: https://pipewire.org/
- **Hyprland**: https://hyprland.org/

### 14.2 Related Projects

- **HyprVoice**: https://github.com/LeonardoTrapani/hyprvoice
- **waystt**: https://github.com/sevos/waystt
- **whisper-overlay**: https://github.com/oddlama/whisper-overlay
- **BlahST**: https://github.com/QuantiusBenignus/BlahST

### 14.3 Protocols & Standards

- **virtual-keyboard-unstable-v1**: https://wayland.app/protocols/virtual-keyboard-unstable-v1
- **wlroots**: https://gitlab.freedesktop.org/wlroots/wlroots

---

## 14.5. Hyprland Keybinding Analysis

### Current Keybinding Patterns

Your Hyprland configuration uses a **Mac-inspired keybinding scheme**:

**Modifier Strategy:**
- `SUPER` (Cmd) = Primary modifier for app launching and window management
- `CTRL` = Workspace navigation with arrow keys
- `SHIFT` combinations = Move operations (window to workspace, etc.)
- Function keys (XF86*) = Hardware-specific controls (audio, brightness, keyboard)

**In Use:**
- SUPER + {T, B, C, E, F, Q, V, {, J, SPACE, L, K, 1-4, 9, arrows}
- SUPER + SHIFT + {S, 1-4, 9, arrows}
- CTRL + {arrows, SPACE}
- CTRL + SHIFT + {arrows}
- XF86* keys (audio, brightness, media)

### Recommended Keybinding for Speech-to-Text

**SUPER + M** - Perfect choice! (Mnemonic: Microphone)
- Currently **unused**
- Matches your app-launch pattern (SUPER+T terminal, SUPER+B browser)
- Easy to remember and reach
- No conflicts with existing 40+ keybindings

**Alternative options:**
- `SUPER + ALT + M` - More isolated, prevents future conflicts
- `ALT + Space` - Opposite of SUPER + Space (rofi)
- `CTRL + ALT + M` - System-level feel
- `F6-F12` - Unused function keys

**Integration Example:**
```conf
# In ~/.config/hypr/hyprland.conf (add around line 203, after app bindings)
bind = SUPER, M, exec, ~/.config/hypr/scripts/speech-to-text.sh
```

### Script Integration Pattern

Your existing scripts follow this pattern:
```bash
#!/bin/bash
# Script placed in: ~/.config/hypr/scripts/
# Uses state management via /tmp/*.pid or /run/user/$UID/*.lock
# Background processes with cleanup traps
# Arguments for mode selection (up/down, toggle, etc.)
```

For speech-to-text, follow the same pattern used in `kbd-breathing.sh` (toggle with PID file state management).

---

## 15. Action Plan

### 15.1 Path A: Quick Win - nerd-dictation (30 min setup)

**Best for**: Getting started fast with acceptable accuracy

```bash
# 1. Install dependencies
pip3 install vosk
yay -S wtype  # or dotool

# 2. Clone and setup
git clone https://github.com/ideasman42/nerd-dictation.git
cd nerd-dictation
wget https://alphacephei.com/kaldi/models/vosk-model-small-en-us-0.15.zip
unzip vosk-model-small-en-us-0.15.zip
mv vosk-model-small-en-us-0.15 model

# 3. Add to hyprland.conf
# bind = SUPER, M, exec, ~/nerd-dictation/nerd-dictation begin --simulate-input-tool=WTYPE
# bind = SUPER_SHIFT, M, exec, ~/nerd-dictation/nerd-dictation end
```

**Result**: Working speech-to-text TODAY with simple setup

---

### 15.2 Path B: Recommended - faster-whisper-dictation (1 hour) ⭐

**Best for**: Best balance of accuracy, performance, and ease of use

```bash
# 1. Install dependencies
yay -S portaudio python-pip wtype
pip install faster-whisper-dictation

# 2. Test it
faster-whisper-dictation --key-combo "<super>+m"

# 3. Make it permanent (add to autostart or systemd service)
# Create systemd user service or add to Hyprland exec-once
```

**Result**: Best-in-class accuracy with simple daemon-based setup

---

### 15.3 Path C: Performance King - whisper.cpp (2 hours)

**Best for**: Maximum performance or hybrid local/remote setup

```bash
# 1. Install whisper.cpp
yay -S whisper.cpp wtype

# 2. Download models
cd ~/.local/share
mkdir -p whisper-models
cd whisper-models
# Download via whisper.cpp model downloader
bash /usr/share/whisper.cpp/download-ggml-model.sh base

# 3. Create custom script (see section 8.1 for example)

# 4. Add keybind to hyprland.conf
# bind = SUPER, M, exec, ~/.config/hypr/scripts/speech-to-text.sh
```

**Result**: Maximum CPU performance, full customization

---

### 15.4 Path D: Ready-Made - HyprVoice

**Best for**: Zero configuration, just want it to work

```bash
# 1. Install
yay -S hyprvoice-bin

# 2. Start service
systemctl --user enable --now hyprvoice

# 3. Add keybind to Hyprland
# bind = SUPER, M, exec, hyprvoicectl start-recording
```

**Result**: Complete working solution, minimal effort

---

### 15.5 Recommended: Start with Path B (faster-whisper-dictation)

This provides:
- ✅ Best accuracy (Whisper models)
- ✅ Good performance (CTranslate2 optimization)
- ✅ Simple setup (pip install)
- ✅ 100% offline and private
- ✅ Daemon-based (no model reload delays)
- ✅ GPU acceleration available

If you encounter issues or want simpler setup, fall back to Path A (nerd-dictation) or Path D (HyprVoice).

---

## Conclusion

### Final Recommendations

**For immediate use**: Install **faster-whisper-dictation** (Path B)
- Best accuracy with Whisper models
- Simple `pip install` setup
- Daemon-based for instant activation
- 100% offline and private

**For simplicity**: Use **nerd-dictation** (Path A) or **HyprVoice** (Path D)
- Proven Wayland compatibility
- Quick setup
- Lower resource requirements

**For performance enthusiasts**: Build **whisper.cpp + custom script** (Path C)
- Maximum CPU performance
- Full customization
- Hybrid local/remote capability

### Technology Stack Summary

| Component | Recommended | Alternative |
|-----------|-------------|-------------|
| **Input Tool** | wtype (simple) | dotool (robust, XWayland) |
| **Audio Capture** | pw-record (PipeWire) | Already installed ✅ |
| **Recognition** | faster-whisper-dictation | nerd-dictation, HyprVoice |
| **Keybinding** | SUPER + M | Customizable |

### Key Advantages

✅ **100% Offline** - All recommended solutions run locally
✅ **Zero Cost** - No API fees, pay once with hardware
✅ **Privacy-First** - No audio sent to cloud services
✅ **Wayland-Safe** - Proper security isolation
✅ **MacBook-Optimized** - Works on your T2 hardware

### What's NOT Possible

❌ **Wispr Flow** - No Linux support (macOS/Windows only)
❌ **Sudo/Lock Screen** - Wayland security prevents injection to elevated contexts
❌ **Zero Latency** - Local processing requires 100ms-2s (still very usable!)

The Wayland security model ensures this approach is safer than X11-based alternatives, with proper isolation between applications while still allowing text injection into user-level focused windows. Your SUPER+M keybinding perfectly fits your existing Hyprland configuration pattern.
