# Solution Design Document

## Validation Checklist

- [ ] All required sections are complete
- [ ] Architecture pattern is clearly stated with rationale
- [ ] Every component has clear responsibility
- [ ] All interfaces are specified
- [ ] Error handling is defined
- [ ] A developer could implement from this design

---

## Constraints

CON-1 **Platform & Environment**
- Must run on Arch Linux with Hyprland (Wayland compositor)
- Must use PipeWire for audio (already installed)
- Must respect Wayland security model (no injection into elevated contexts)
- Must work with existing Hyprland configuration patterns

CON-2 **Performance & Resource**
- Transcription latency must be < 500ms on CPU, < 100ms with GPU
- Recording start latency < 100ms for responsive feel
- RAM usage: ~150-500MB for Whisper model
- Disk usage: ~2GB for models and dependencies

CON-3 **Privacy & Security**
- 100% offline operation (no cloud APIs)
- Zero telemetry or usage tracking
- Temporary audio files must be cleaned up immediately
- Cannot bypass Wayland security restrictions

---

## Architecture Overview

### Architecture Pattern: External Service Integration

**Pattern**: Integrate faster-whisper-dictation (external Python daemon) with Hyprland via keybinding configuration

**Rationale**:
- faster-whisper-dictation provides complete speech-to-text functionality
- No need to reimplement Whisper inference or audio processing
- Daemon architecture (persistent process) avoids model reload delays
- Hyprland keybinding provides trigger mechanism
- wtype provides Wayland-native text injection

**Alternative Considered**: Custom script with whisper.cpp
- **Rejected**: More complex, requires custom integration code, slower time-to-value

### System Context Diagram

```
┌─────────────────────────────────────────────────────────┐
│                     User's System                        │
│                                                          │
│  ┌──────────────┐                                       │
│  │  Hyprland    │ SUPER+M keybind                       │
│  │  Compositor  │────────────────┐                      │
│  └──────────────┘                │                      │
│                                   ▼                      │
│  ┌────────────────────────────────────────────────┐    │
│  │  faster-whisper-dictation (daemon)             │    │
│  │  ┌──────────────────────────────────────────┐  │    │
│  │  │ 1. Capture audio (via PipeWire)          │  │    │
│  │  │ 2. Transcribe (Whisper model, offline)   │  │    │
│  │  │ 3. Inject text (via wtype)               │  │    │
│  │  └──────────────────────────────────────────┘  │    │
│  └────────────────────────────────────────────────┘    │
│         │                    │                          │
│         ▼                    ▼                          │
│  ┌─────────────┐      ┌──────────────┐                │
│  │  PipeWire   │      │    wtype     │                │
│  │ (pw-record) │      │ (Wayland VK) │                │
│  └─────────────┘      └──────────────┘                │
│         │                    │                          │
│         ▼                    ▼                          │
│  ┌─────────────┐      ┌──────────────────────────┐    │
│  │ Microphone  │      │ Focused Application      │    │
│  │  Hardware   │      │ (Terminal/Browser/Editor)│    │
│  └─────────────┘      └──────────────────────────┘    │
└─────────────────────────────────────────────────────────┘

External Dependencies:
- faster-whisper-dictation (PyPI package)
- wtype (Arch package)
- PipeWire (already installed)
```

---

## Component Design

### C1: Hyprland Keybinding Configuration
**Responsibility**: Trigger faster-whisper-dictation on SUPER+M keypress

**Location**: `dotfiles/hypr/hyprland.conf`

**Interface**:
```conf
# Add to keybindings section (around line 203)
# faster-whisper-dictation handles the entire workflow
# No script needed - daemon listens for configured key combo
```

**Implementation Notes**:
- faster-whisper-dictation daemon is configured with `--key-combo "<super>+m"`
- Daemon handles key detection, recording, transcription, and injection
- Hyprland does not need explicit keybinding (daemon captures it directly)

### C2: faster-whisper-dictation Service
**Responsibility**: Run faster-whisper-dictation daemon on system startup

**Location**: `~/.config/systemd/user/faster-whisper-dictation.service`

**Interface**:
```ini
[Unit]
Description=Faster Whisper Dictation Service
After=graphical-session.target

[Service]
Type=simple
ExecStart=/usr/bin/faster-whisper-dictation --key-combo "<super>+m" --model base
Restart=on-failure
RestartSec=5

[Install]
WantedBy=default.target
```

**Implementation Notes**:
- Systemd user service ensures daemon starts on login
- `--model base` for good accuracy/speed tradeoff (can be adjusted)
- Restart on failure for reliability

### C3: Audio Capture (PipeWire)
**Responsibility**: Provide microphone audio to faster-whisper-dictation

**Location**: System-level PipeWire (already configured)

**Interface**: faster-whisper-dictation uses PipeWire API internally

**Implementation Notes**:
- No configuration needed (PipeWire already working)
- Validate microphone works: `pw-record --rate=16000 test.wav` (Ctrl+C to stop)
- faster-whisper-dictation handles audio format (16kHz mono) automatically

### C4: Text Injection (wtype)
**Responsibility**: Inject transcribed text into focused Wayland window

**Location**: System package (`/usr/bin/wtype`)

**Interface**: faster-whisper-dictation calls wtype internally

**Implementation Notes**:
- Install via: `sudo pacman -S wtype`
- Uses Wayland virtual-keyboard protocol
- No explicit configuration needed
- Works with all Wayland applications (native and XWayland)

---

## Data Flow

### Primary Flow: Voice Dictation

```
1. User Action: Press SUPER+M
   ↓
2. faster-whisper-dictation detects keypress
   ↓
3. Start audio recording (PipeWire/pw-record)
   ↓
4. Show notification: "Recording..."
   ↓
5. User speaks (up to 10 seconds or until key release)
   ↓
6. User Action: Release SUPER+M
   ↓
7. Stop audio recording, save to /tmp/whisper-*.wav
   ↓
8. Show notification: "Transcribing..."
   ↓
9. Transcribe audio using local Whisper model
   ↓
10. Delete temporary audio file
   ↓
11. Inject text via wtype into focused window
   ↓
12. Show notification: "Injected: [transcribed text]"
```

### Data Specifications

**Audio Data**:
- Format: WAV (16-bit PCM)
- Sample Rate: 16000 Hz (16 kHz)
- Channels: Mono (1 channel)
- Storage: `/tmp/whisper-*.wav` (temporary, deleted after transcription)
- Max Duration: 10 seconds

**Transcription Data**:
- Type: Plain text string (UTF-8)
- Processing: Whisper model inference (base or small model)
- Latency: 200-500ms (CPU), <100ms (GPU)
- Accuracy: Includes capitalization and punctuation

---

## Error Handling

### E1: Microphone Not Available
**Detection**: faster-whisper-dictation cannot access PipeWire input
**Response**: Show notification "Microphone not available"
**Recovery**: User checks PipeWire configuration, restarts daemon

### E2: Transcription Fails
**Detection**: Whisper model returns empty or error
**Response**: Show notification "Transcription failed"
**Recovery**: User retries recording, checks audio quality

### E3: No Speech Detected
**Detection**: Audio file empty or silent
**Response**: Show notification "No speech detected"
**Recovery**: User speaks louder, checks microphone

### E4: Daemon Not Running
**Detection**: User presses SUPER+M but nothing happens
**Response**: N/A (no feedback if daemon not running)
**Recovery**: User starts daemon: `systemctl --user start faster-whisper-dictation`

### E5: wtype Injection Fails
**Detection**: Text not appearing in focused window
**Response**: Fall back to clipboard (if configured)
**Recovery**: User manually pastes from clipboard

---

## Quality Requirements

### QR-1: Performance
- **Requirement**: Transcription latency < 500ms on CPU, < 100ms with GPU
- **Measurement**: Time from "Recording stopped" to "Text injected"
- **Implementation**: Use base Whisper model (142MB), optimize with CTranslate2
- **Test**: Record 5-second speech sample, measure transcription time

### QR-2: Accuracy
- **Requirement**: Transcription accuracy > 95% (minimal corrections needed)
- **Measurement**: Word Error Rate (WER) on sample dictations
- **Implementation**: Use Whisper base or small model (proven accuracy)
- **Test**: Dictate technical content, count errors/corrections needed

### QR-3: Reliability
- **Requirement**: Service uptime > 99% (daemon restarts on failure)
- **Measurement**: Service availability checks
- **Implementation**: Systemd restart policy, robust error handling
- **Test**: Kill daemon process, verify automatic restart

### QR-4: Privacy
- **Requirement**: 100% offline operation, zero data leakage
- **Measurement**: Network traffic monitoring during usage
- **Implementation**: No cloud APIs, local Whisper model, immediate file cleanup
- **Test**: Monitor network with Wireshark, verify no external connections

---

## Dependencies

### System Dependencies
```bash
# Required packages
sudo pacman -S wtype              # Text injection
sudo pacman -S python python-pip  # Python environment
sudo pacman -S portaudio          # Audio library for faster-whisper

# Python package
pip install faster-whisper-dictation
```

### Whisper Model
- **Default**: base model (142 MB)
- **Alternatives**: tiny (39 MB, faster but less accurate), small (466 MB, more accurate)
- **Download**: Automatic on first run by faster-whisper-dictation
- **Location**: `~/.cache/huggingface/` or similar

---

## Configuration

### faster-whisper-dictation Configuration

**Launch Options**:
```bash
# Basic usage with default key combo
faster-whisper-dictation

# Custom key combo and model
faster-whisper-dictation --key-combo "<super>+m" --model base

# With GPU acceleration
faster-whisper-dictation --key-combo "<super>+m" --model base --device cuda
```

**Configuration File**: None required (all configuration via command-line args)

### Systemd Service Configuration

**File**: `~/.config/systemd/user/faster-whisper-dictation.service`

```ini
[Unit]
Description=Faster Whisper Dictation Service
After=graphical-session.target

[Service]
Type=simple
ExecStart=/home/miro/.local/bin/faster-whisper-dictation --key-combo "<super>+m" --model base
Restart=on-failure
RestartSec=5

[Install]
WantedBy=default.target
```

**Enable and Start**:
```bash
systemctl --user daemon-reload
systemctl --user enable faster-whisper-dictation.service
systemctl --user start faster-whisper-dictation.service
```

---

## Deployment Strategy

### Installation Steps

1. **Install System Dependencies**
   ```bash
   sudo pacman -S wtype python python-pip portaudio
   ```

2. **Install faster-whisper-dictation**
   ```bash
   pip install faster-whisper-dictation
   ```

3. **Create Systemd Service**
   ```bash
   mkdir -p ~/.config/systemd/user
   cat > ~/.config/systemd/user/faster-whisper-dictation.service << 'EOF'
   [Unit]
   Description=Faster Whisper Dictation Service
   After=graphical-session.target

   [Service]
   Type=simple
   ExecStart=/home/miro/.local/bin/faster-whisper-dictation --key-combo "<super>+m" --model base
   Restart=on-failure
   RestartSec=5

   [Install]
   WantedBy=default.target
   EOF
   ```

4. **Enable and Start Service**
   ```bash
   systemctl --user daemon-reload
   systemctl --user enable faster-whisper-dictation.service
   systemctl --user start faster-whisper-dictation.service
   ```

5. **Verify Installation**
   ```bash
   # Check service status
   systemctl --user status faster-whisper-dictation

   # Test microphone
   pw-record --rate=16000 test.wav  # Ctrl+C to stop

   # Test voice dictation
   # Press SUPER+M, speak, release key, verify text injection
   ```

### Rollback Strategy

If faster-whisper-dictation doesn't work:

**Option 1**: Try alternative model size
```bash
systemctl --user stop faster-whisper-dictation
# Edit service file to use --model tiny or --model small
systemctl --user daemon-reload
systemctl --user start faster-whisper-dictation
```

**Option 2**: Fall back to HyprVoice (ready-made alternative)
```bash
yay -S hyprvoice-bin
systemctl --user enable --now hyprvoice
# Add keybinding to hyprland.conf
```

**Option 3**: Fall back to nerd-dictation (simpler but less accurate)
```bash
pip install vosk
git clone https://github.com/ideasman42/nerd-dictation.git
# Configure with SUPER+M keybinding
```

---

## Testing Strategy

### Unit Testing
N/A - Using external package (faster-whisper-dictation), no custom code to unit test

### Integration Testing

**Test 1: End-to-End Dictation**
1. Press SUPER+M
2. Speak: "This is a test sentence with punctuation."
3. Release SUPER+M
4. Verify text appears in focused window with capitalization and period

**Test 2: Error Handling - No Speech**
1. Press SUPER+M
2. Stay silent for 2 seconds
3. Release SUPER+M
4. Verify notification "No speech detected" appears

**Test 3: Performance - Latency**
1. Press SUPER+M
2. Speak 5-second sentence
3. Release SUPER+M
4. Measure time until text appears
5. Verify latency < 500ms

**Test 4: Reliability - Service Restart**
1. Kill daemon: `pkill -f faster-whisper-dictation`
2. Wait 10 seconds
3. Verify service auto-restarted: `systemctl --user status faster-whisper-dictation`

**Test 5: Cross-Application Compatibility**
1. Test dictation in terminal (Alacritty)
2. Test dictation in browser (Firefox)
3. Test dictation in text editor (Cursor/VSCode)
4. Verify text injection works in all applications

---

## Security Considerations

### S1: Wayland Security Model
- faster-whisper-dictation respects Wayland security
- Cannot inject text into sudo prompts or lock screens
- Cannot access focused window content (only inject text)

### S2: Audio Privacy
- Audio files stored in /tmp (memory-backed filesystem)
- Files deleted immediately after transcription
- No audio sent to external services
- No persistent recording storage

### S3: No Privilege Escalation
- Runs as user-level service (not root)
- Uses standard Wayland protocols (virtual-keyboard)
- No system-level configuration changes required

### S4: Dependency Trust
- faster-whisper-dictation: Open-source, auditable Python package
- wtype: Open-source, minimal C program
- Whisper models: OpenAI pretrained models (checksummed downloads)

---

## Maintenance Considerations

### Updates
- **faster-whisper-dictation**: Update via `pip install --upgrade faster-whisper-dictation`
- **wtype**: Update via `sudo pacman -Syu`
- **Whisper models**: Auto-downloaded/cached, no manual updates needed

### Monitoring
- Check service status: `systemctl --user status faster-whisper-dictation`
- View logs: `journalctl --user -u faster-whisper-dictation -f`
- Resource usage: `ps aux | grep faster-whisper`

### Troubleshooting Commands
```bash
# Restart service
systemctl --user restart faster-whisper-dictation

# Check logs
journalctl --user -u faster-whisper-dictation --since "1 hour ago"

# Test microphone
pw-record --rate=16000 test.wav

# Test wtype
wtype "test text injection"

# Verify dependencies
pip show faster-whisper-dictation
which wtype
```

---

## Open Technical Questions

- [x] Which Whisper model size (tiny/base/small/medium) works best on MacBook Pro T2? → **Start with base, test latency**
- [x] Does faster-whisper-dictation support custom key combo configuration? → **Yes, via --key-combo argument**
- [x] How to handle daemon crashes? → **Systemd restart policy**
- [ ] Should we enable GPU acceleration if available? → **Defer to implementation testing**
- [ ] What's the optimal Whisper model for battery life? → **Base model likely best tradeoff**

---

## Alternatives Considered

### Alternative 1: Custom Script with whisper.cpp
**Pros**: Maximum performance, full control
**Cons**: Complex implementation, more maintenance
**Decision**: Rejected - faster-whisper-dictation provides better UX with less complexity

### Alternative 2: nerd-dictation (VOSK-based)
**Pros**: Simpler setup, lower resource usage
**Cons**: Lower accuracy, lowercase-only output
**Decision**: Rejected for primary solution - keep as fallback option

### Alternative 3: HyprVoice
**Pros**: Ready-made, zero configuration
**Cons**: Less flexible, may not match exact requirements
**Decision**: Keep as rollback option if faster-whisper-dictation fails

### Alternative 4: OpenAI Whisper API
**Pros**: Best accuracy, no local compute
**Cons**: Defeats privacy goal, costs money, requires internet
**Decision**: Rejected - contradicts core requirements

---

## Success Criteria

Implementation is successful when:
1. ✅ User can press SUPER+M to activate voice dictation
2. ✅ Transcription accuracy > 95% on clear speech
3. ✅ Latency < 500ms from key release to text injection
4. ✅ Works in terminal, browser, and text editor
5. ✅ Service auto-starts on login
6. ✅ No network traffic during usage (100% offline)
7. ✅ Setup completes in < 1 hour
