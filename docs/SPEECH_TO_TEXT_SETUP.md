# Speech-to-Text Dictation Setup

**Implementation Date**: 2025-11-11
**Status**: ✅ Production Ready
**Method**: Hold-to-Record with Whisper Base Model

---

## 🎯 Overview

Voice dictation system for Hyprland using local Whisper AI model. Press and hold CMD+M to record, release to transcribe and type the text automatically.

### Key Features

- ✅ **Hold-to-Record**: Natural push-to-talk interface
- ✅ **100% Offline**: No cloud services, complete privacy
- ✅ **Fast Transcription**: Model preloaded in memory (~150MB RAM)
- ✅ **Audio Feedback**: Beeps on start/stop recording
- ✅ **Visual Feedback**: Persistent notification while recording
- ✅ **Edge Case Handling**: Too short, no speech, no audio detection
- ✅ **Memory Safe**: Automatic cleanup of temporary files

---

## 📐 Architecture

```
┌─────────────────────────────────────────────────────────────┐
│ User holds CMD+M                                            │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│ Hyprland Keybind (bind + bindr)                            │
│ - bind:  Triggers speech-start.sh (on press)               │
│ - bindr: Triggers speech-stop.sh (on release)              │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│ Speech Daemon (systemd user service)                       │
│ - Whisper base model loaded in RAM (150MB)                 │
│ - Listens on Unix socket: /tmp/speech-to-text.sock         │
│ - Accepts START/STOP commands                              │
│ - Handles recording via PipeWire (pw-record)                │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│ Workflow                                                    │
│ 1. START command → Begin pw-record in background           │
│ 2. User speaks while holding key                           │
│ 3. STOP command → Kill pw-record, transcribe audio         │
│ 4. Return transcribed text via socket                      │
│ 5. wtype injects text at cursor position                   │
└─────────────────────────────────────────────────────────────┘
```

---

## 📦 Components

### 1. Daemon (`speech-daemon.service`)

**Location**: `~/.config/systemd/user/speech-daemon.service`

**Purpose**: Background service that keeps Whisper model loaded

**Key Features**:
- Thread-safe state management
- Automatic temp file cleanup
- Graceful shutdown handling
- Edge case detection (too short, no audio, no speech)

**Resource Usage**:
- Memory: ~150MB constant (Whisper base model)
- CPU: Near-zero idle, spikes during transcription
- Auto-starts on login

### 2. Start Script (`speech-start.sh`)

**Location**: `~/.config/hypr/scripts/speech-start.sh`

**Triggered**: When CMD+M is **pressed**

**Actions**:
1. Play start beep (`granted-04.wav`)
2. Show persistent notification "🎙️ Recording..."
3. Send START command to daemon
4. Daemon begins pw-record in background

### 3. Stop Script (`speech-stop.sh`)

**Location**: `~/.config/hypr/scripts/speech-stop.sh`

**Triggered**: When CMD+M is **released**

**Actions**:
1. Update notification to "✨ Transcribing..."
2. Send STOP command to daemon
3. Daemon stops recording, transcribes, returns text
4. Play end beep (`beepbeep.wav`)
5. Inject text via `wtype`
6. Show success notification with transcribed text

### 4. Python Daemon (`speech-daemon.py`)

**Location**: `~/.config/hypr/scripts/speech-daemon.py`

**Key Functions**:
- `start_recording()`: Spawns pw-record subprocess
- `stop_recording()`: Kills subprocess, validates audio file
- `transcribe()`: Uses Whisper model to convert speech to text
- `cleanup_on_shutdown()`: Ensures no temp files left behind

**Error Handling**:
- `TOO_SHORT`: Recording <0.5 seconds
- `NO_AUDIO`: File empty or <1KB
- `NO_SPEECH`: Whisper detected no words
- `NOT_RECORDING`: STOP called when not recording
- `ALREADY_RECORDING`: START called while recording

---

## 🔧 Configuration

### Hyprland Keybinds

```conf
# Speech-to-Text (Hold CMD+M to record)
bind  = SUPER, M, exec, ~/.config/hypr/scripts/speech-start.sh
bindr = SUPER, M, exec, ~/.config/hypr/scripts/speech-stop.sh
```

### Systemd Service

```ini
[Unit]
Description=Speech-to-Text Daemon (Preloaded Whisper Model)
After=graphical-session.target

[Service]
Type=simple
ExecStart=/home/miro/faster-whisper-dictation/venv/bin/python /home/miro/.config/hypr/scripts/speech-daemon.py
Restart=on-failure
RestartSec=5

Environment="XDG_RUNTIME_DIR=/run/user/1000"
Environment="PIPEWIRE_RUNTIME_DIR=/run/user/1000"
Environment="PULSE_RUNTIME_PATH=/run/user/1000/pulse"

[Install]
WantedBy=default.target
```

---

## 📝 Dependencies

### System Packages (Arch Linux)

```bash
sudo pacman -S wtype python python-pip portaudio
```

### Python Environment

Located at: `/home/miro/faster-whisper-dictation/venv`

**Key packages**:
- `faster-whisper` - Optimized Whisper inference
- `soundfile` - Audio file handling
- `numpy` - Audio processing

### Audio System

- **PipeWire**: Audio server (already installed)
- **pw-record**: Recording tool (part of pipewire)
- **paplay**: Audio playback for beeps (part of pipewire)

### Microphone

- **Target**: `alsa_input.pci-0000_02_00.3.BuiltinMic`
- **Format**: 16kHz, mono, 16-bit PCM

---

## 🎮 Usage

### Basic Usage

1. **Focus** any text input field (terminal, browser, editor, chat)
2. **Press and HOLD** CMD+M (SUPER+M)
   - 🔊 Start beep plays
   - 💬 "🎙️ Recording..." notification appears
3. **Speak clearly** into microphone
4. **Release** CMD+M when done
   - 🔊 End beep plays
   - 💬 "✨ Transcribing..." notification
   - Text appears at cursor
   - ✅ "Typed Successfully: [text]" notification

### Tips for Best Results

- **Speak clearly** at normal conversation volume
- **Hold for at least 0.5 seconds** (minimum duration)
- **Natural speech** works best - no need to over-enunciate
- **Background noise** should be minimal for accuracy
- **Technical terms** may need correction

---

## 🛠️ Management Commands

### Check Service Status

```bash
systemctl --user status speech-daemon
```

### View Logs

```bash
journalctl --user -u speech-daemon -f
```

### Restart Service

```bash
systemctl --user restart speech-daemon
```

### Disable Auto-Start

```bash
systemctl --user disable speech-daemon
```

### Manual Test

```bash
# Test START command
python3 -c "
import socket
sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
sock.connect('/tmp/speech-to-text.sock')
sock.sendall(b'START')
sock.shutdown(socket.SHUT_WR)
print(sock.recv(1024).decode())
sock.close()
"

# Wait and speak, then test STOP
python3 -c "
import socket
sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
sock.connect('/tmp/speech-to-text.sock')
sock.sendall(b'STOP')
sock.shutdown(socket.SHUT_WR)
print(sock.recv(4096).decode())
sock.close()
"
```

---

## 🐛 Troubleshooting

### No Beep Sound

**Symptom**: Notification shows but no audio feedback

**Solutions**:
1. Check audio output: `pactl list sinks short`
2. Test beep manually: `paplay ~/.../granted-04.wav`
3. Verify PipeWire running: `systemctl --user status pipewire`

### "Daemon not running" Error

**Symptom**: Notification says daemon isn't running

**Solutions**:
1. Check service: `systemctl --user status speech-daemon`
2. Check socket exists: `ls -l /tmp/speech-to-text.sock`
3. Restart daemon: `systemctl --user restart speech-daemon`
4. Check logs: `journalctl --user -u speech-daemon --since "5 minutes ago"`

### "No speech detected" Error

**Symptom**: Recording completes but no text appears

**Possible Causes**:
1. **Too quiet**: Speak louder into microphone
2. **Wrong mic**: Check `pactl get-default-source`
3. **Mic muted**: Check `pactl get-source-mute @DEFAULT_SOURCE@`
4. **Background noise**: Move to quieter environment
5. **Actual silence**: Make sure you're speaking

### "Recording too short" Error

**Symptom**: Release key immediately, get error

**Solution**: Hold CMD+M for at least 0.5 seconds while speaking

### Text Has Extra Characters

**Symptom**: Whisper adds punctuation or filler words

**Notes**:
- Whisper sometimes adds periods, commas based on context
- May transcribe "um", "uh", "like" if spoken
- This is normal behavior for the model

### High CPU Usage

**Symptom**: CPU spike during transcription

**Expected**: Whisper uses ~50-70% of one CPU core during transcription (1-2 seconds)

**If prolonged**: Check for multiple daemon instances: `ps aux | grep speech-daemon`

---

## 🔒 Security & Privacy

### Privacy Benefits

- ✅ **100% Offline**: No audio sent to cloud
- ✅ **No Logging**: Audio files deleted immediately after transcription
- ✅ **Local Processing**: All AI inference on your machine
- ✅ **No Accounts**: No API keys or third-party services

### Data Flow

1. Audio captured to `/tmp/speech-XXXXXX.wav` (temporary)
2. Transcribed locally using Whisper model
3. Temp file deleted immediately after transcription
4. No persistent storage of audio or transcriptions

### Wayland Security

- Cannot inject into elevated prompts (sudo, polkit)
- Cannot inject into lock screen
- Safer than X11 architecture

---

## 📊 Performance Metrics

### Latency Breakdown

- **Recording**: 0ms overhead (starts immediately)
- **Transcription**: ~500-1000ms (depends on audio length)
- **Text Injection**: ~100ms (wtype delay)
- **Total**: ~600-1100ms after releasing key

### Resource Usage

- **RAM**: 150MB constant (Whisper model)
- **Disk**: 0MB (no persistent storage)
- **CPU Idle**: <1%
- **CPU Active**: 50-70% single core for 1-2s during transcription

### Model Details

- **Model**: Whisper base (English)
- **Size**: ~142MB
- **Accuracy**: ~95% for clear speech
- **Language**: English-optimized (can detect others with lower accuracy)

---

## 🔮 Future Enhancements

### Potential Improvements

1. **GPU Acceleration**: Use CUDA/ROCm if available
2. **Model Selection**: Allow switching between tiny/base/small models
3. **Language Selection**: Multi-language support
4. **Custom Vocabulary**: Train on technical terms
5. **Punctuation Commands**: "period", "comma", "new line"
6. **Correction Mode**: Re-record last phrase
7. **History**: Save transcription history
8. **Clipboard Mode**: Option to copy instead of type

### Known Limitations

- Fixed model (base) - no runtime model switching
- English-optimized - other languages less accurate
- No real-time streaming - must finish recording first
- No custom wake words or activation phrases
- No integration with text editors for context-aware completion

---

## 📚 References

### Research Documentation

See `docs/SPEECH_TO_TEXT_RESEARCH.md` for:
- Technology evaluation (whisper.cpp vs alternatives)
- Input simulation comparison (wtype vs dotool vs ydotool)
- Wayland security model
- Alternative solutions (nerd-dictation, HyprVoice, etc.)

### External Resources

- [faster-whisper GitHub](https://github.com/guillaumekln/faster-whisper)
- [Whisper Model Card](https://github.com/openai/whisper)
- [wtype Documentation](https://github.com/atx/wtype)
- [PipeWire Documentation](https://pipewire.org/)

---

## ✅ Verification Checklist

After setup, verify:

- [ ] Daemon service is running: `systemctl --user status speech-daemon`
- [ ] Model loaded successfully (check logs for "Model loaded!")
- [ ] Socket exists: `ls /tmp/speech-to-text.sock`
- [ ] Hyprland config has both bind and bindr for SUPER+M
- [ ] Start beep plays when pressing CMD+M
- [ ] Notification appears while holding key
- [ ] End beep plays when releasing CMD+M
- [ ] Text appears at cursor after transcription
- [ ] No temp files left behind: `ls /tmp/speech-*.wav`
- [ ] Service auto-starts on login

---

**Implementation Status**: ✅ Complete and Production Ready
**Last Updated**: 2025-11-11
**Maintainer**: Balder System Configuration
