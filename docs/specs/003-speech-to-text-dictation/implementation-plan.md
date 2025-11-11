# Implementation Plan

## Execution Summary

**Specification**: #003 - Speech-to-Text Dictation
**Approach**: Install and configure faster-whisper-dictation as systemd user service
**Estimated Time**: 1 hour
**Risk Level**: Low (using proven external package, simple configuration)

---

## Implementation Phases

### Phase 1: Environment Validation
**Goal**: Ensure system prerequisites are met before installation

**Activities**:
1. Verify PipeWire audio system is working
2. Verify microphone is available and functional
3. Verify Python environment is available
4. Verify disk space for Whisper models (~2GB)

**Validation**:
```bash
# Test microphone with PipeWire
pw-record --rate=16000 /tmp/mic-test.wav
# Speak for 2 seconds, then Ctrl+C
# Listen back to verify audio quality
ffplay /tmp/mic-test.wav
rm /tmp/mic-test.wav

# Check Python version (need 3.8+)
python3 --version

# Check available disk space
df -h ~

# Verify pip is available
pip --version
```

**Success Criteria**:
- Microphone records clear audio via PipeWire
- Python 3.8+ is installed
- At least 3GB free disk space available
- pip package manager is functional

**Rollback**: N/A (validation only, no changes made)

---

### Phase 2: Install System Dependencies
**Goal**: Install required Arch Linux packages

**Activities**:
1. Install wtype (text injection tool)
2. Install portaudio (audio library dependency)
3. Verify python and pip are up to date

**Commands**:
```bash
# Install system packages
sudo pacman -S wtype python python-pip portaudio

# Verify installations
which wtype
python3 --version
pip --version
```

**Validation**:
```bash
# Test wtype
wtype "test" && echo " - wtype works!"

# Verify portaudio library
pacman -Qi portaudio
```

**Success Criteria**:
- wtype binary available at `/usr/bin/wtype`
- portaudio package installed
- python3 and pip functional

**Rollback**:
```bash
# If needed, remove installed packages
sudo pacman -R wtype portaudio
```

---

### Phase 3: Install faster-whisper-dictation
**Goal**: Install Python package and dependencies

**Activities**:
1. Install faster-whisper-dictation via pip
2. Verify installation
3. Test command-line execution

**Commands**:
```bash
# Install faster-whisper-dictation
pip install faster-whisper-dictation

# Verify installation
pip show faster-whisper-dictation

# Check binary location (should be in ~/.local/bin/)
which faster-whisper-dictation || find ~/.local/bin -name "faster-whisper-dictation"
```

**Validation**:
```bash
# Test help output
faster-whisper-dictation --help

# Verify it can be executed
~/.local/bin/faster-whisper-dictation --help 2>&1 | head -5
```

**Success Criteria**:
- faster-whisper-dictation package installed
- Binary available in `~/.local/bin/`
- Help command executes without errors

**Rollback**:
```bash
# Uninstall if needed
pip uninstall faster-whisper-dictation
```

---

### Phase 4: Create Systemd User Service
**Goal**: Configure faster-whisper-dictation to auto-start on login

**Activities**:
1. Create systemd user service directory
2. Write service configuration file
3. Set correct paths for user home directory

**Commands**:
```bash
# Create systemd user directory
mkdir -p ~/.config/systemd/user

# Create service file
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

# Reload systemd daemon
systemctl --user daemon-reload
```

**Validation**:
```bash
# Verify service file exists
ls -lh ~/.config/systemd/user/faster-whisper-dictation.service

# Check service can be loaded
systemctl --user status faster-whisper-dictation
```

**Success Criteria**:
- Service file created in correct location
- systemd recognizes the service unit
- No syntax errors in service configuration

**Rollback**:
```bash
# Remove service file
rm ~/.config/systemd/user/faster-whisper-dictation.service
systemctl --user daemon-reload
```

---

### Phase 5: Start and Enable Service
**Goal**: Launch faster-whisper-dictation daemon and configure auto-start

**Activities**:
1. Start the service
2. Monitor initial startup and model download
3. Enable service for auto-start on login
4. Verify service is running

**Commands**:
```bash
# Start the service
systemctl --user start faster-whisper-dictation

# Watch logs for initial startup (Whisper model download)
journalctl --user -u faster-whisper-dictation -f
# NOTE: First run will download ~142MB base model, may take 2-5 minutes
# Press Ctrl+C once you see "Service started" or similar message

# Enable auto-start on login
systemctl --user enable faster-whisper-dictation

# Check service status
systemctl --user status faster-whisper-dictation
```

**Validation**:
```bash
# Verify service is active
systemctl --user is-active faster-whisper-dictation

# Check for errors in logs
journalctl --user -u faster-whisper-dictation --since "5 minutes ago" | grep -i error

# Verify model was downloaded
ls ~/.cache/huggingface/ || ls ~/.local/share/ | grep -i whisper
```

**Success Criteria**:
- Service status shows "active (running)"
- Whisper base model downloaded successfully
- Service enabled for auto-start
- No errors in recent logs

**Rollback**:
```bash
# Stop and disable service
systemctl --user stop faster-whisper-dictation
systemctl --user disable faster-whisper-dictation
```

---

### Phase 6: End-to-End Testing
**Goal**: Validate voice dictation works across multiple applications

**Activities**:
1. Test basic dictation in terminal
2. Test in browser
3. Test in text editor
4. Verify transcription accuracy and latency
5. Test error scenarios

**Test Cases**:

**Test 1: Basic Dictation (Terminal)**
```
1. Open Alacritty terminal
2. Press SUPER+M
3. Speak: "This is a test of voice dictation."
4. Release SUPER+M
5. Verify text appears with capitalization and period
6. Verify latency < 1 second
```

**Test 2: Browser Dictation**
```
1. Open Firefox, navigate to any text input (e.g., Google search)
2. Focus the input field
3. Press SUPER+M
4. Speak: "artificial intelligence and machine learning"
5. Release SUPER+M
6. Verify text appears correctly
```

**Test 3: Text Editor Dictation**
```
1. Open Cursor or VSCode
2. Create new file
3. Press SUPER+M
4. Speak: "Function declarations should include type annotations for better code quality."
5. Release SUPER+M
6. Verify technical terms transcribed correctly
```

**Test 4: Error - No Speech**
```
1. Press SUPER+M
2. Stay silent for 3 seconds
3. Release SUPER+M
4. Verify notification "No speech detected" or similar appears
```

**Test 5: Service Reliability**
```bash
# Kill daemon
pkill -f faster-whisper-dictation

# Wait 10 seconds
sleep 10

# Verify service auto-restarted
systemctl --user status faster-whisper-dictation
```

**Validation**:
```bash
# Check service uptime
systemctl --user status faster-whisper-dictation | grep "Active:"

# Review logs for any errors during testing
journalctl --user -u faster-whisper-dictation --since "10 minutes ago"
```

**Success Criteria**:
- Voice dictation works in terminal, browser, and text editor
- Transcription accuracy > 95% (minimal corrections needed)
- Latency < 500ms average
- Error scenarios handled gracefully
- Service restarts automatically after crash

**Rollback**: See "Rollback to Alternative Solutions" below

---

## Rollback to Alternative Solutions

If faster-whisper-dictation doesn't meet requirements, fall back to alternatives:

### Option 1: Try Different Whisper Model
```bash
# Stop service
systemctl --user stop faster-whisper-dictation

# Edit service file to use smaller/larger model
sed -i 's/--model base/--model small/' ~/.config/systemd/user/faster-whisper-dictation.service

# Reload and restart
systemctl --user daemon-reload
systemctl --user start faster-whisper-dictation

# Test again
```

### Option 2: Fall Back to HyprVoice
```bash
# Stop faster-whisper-dictation
systemctl --user stop faster-whisper-dictation
systemctl --user disable faster-whisper-dictation

# Install HyprVoice
yay -S hyprvoice-bin

# Start HyprVoice service
systemctl --user enable --now hyprvoice

# Test with SUPER+M
```

### Option 3: Fall Back to nerd-dictation
```bash
# Stop faster-whisper-dictation
systemctl --user stop faster-whisper-dictation
systemctl --user disable faster-whisper-dictation

# Install nerd-dictation
pip install vosk
git clone https://github.com/ideasman42/nerd-dictation.git ~/nerd-dictation
cd ~/nerd-dictation
wget https://alphacephei.com/kaldi/models/vosk-model-small-en-us-0.15.zip
unzip vosk-model-small-en-us-0.15.zip
mv vosk-model-small-en-us-0.15 model

# Add keybinding to hyprland.conf manually
# bind = SUPER, M, exec, ~/nerd-dictation/nerd-dictation begin --simulate-input-tool=WTYPE
# bind = SUPER_SHIFT, M, exec, ~/nerd-dictation/nerd-dictation end
```

---

## Dependencies Between Phases

```
Phase 1 (Validation) → Required before all other phases
    ↓
Phase 2 (System Deps) → Required for Phase 3
    ↓
Phase 3 (Install Package) → Required for Phase 4
    ↓
Phase 4 (Create Service) → Required for Phase 5
    ↓
Phase 5 (Start Service) → Required for Phase 6
    ↓
Phase 6 (Testing) → Final validation
```

**Critical Path**: All phases must complete sequentially. No parallel execution possible.

---

## Success Metrics

### Implementation Success
- [ ] All 6 phases completed without errors
- [ ] Service running and enabled for auto-start
- [ ] Voice dictation works in at least 3 different applications
- [ ] Transcription accuracy > 95%
- [ ] Latency < 500ms average
- [ ] No network traffic detected during usage

### Time to Value
- [ ] Setup completed in < 1 hour
- [ ] First successful dictation within 5 minutes of service start

### Quality
- [ ] Service auto-restarts on failure
- [ ] No memory leaks (service runs stable for 24 hours)
- [ ] Works across Wayland and XWayland applications

---

## Post-Implementation

### Documentation
- Update docs/SPEECH_TO_TEXT_RESEARCH.md with actual implementation results
- Document any issues encountered and solutions
- Note actual transcription latency measured on MacBook Pro T2

### Optional Enhancements
After core implementation is stable, consider:
1. **GPU Acceleration**: Test with `--device cuda` if NVIDIA GPU available
2. **Model Optimization**: Test different model sizes (tiny/base/small) for battery life
3. **Configuration File**: Create config file for easier model/key combo changes
4. **Desktop Notifications**: Verify notifications are helpful (or disable if distracting)
5. **Waybar Integration**: Add indicator showing service status

### Monitoring
```bash
# Check service health daily
systemctl --user status faster-whisper-dictation

# Review logs for errors
journalctl --user -u faster-whisper-dictation --since yesterday | grep -i error

# Monitor resource usage
ps aux | grep faster-whisper | awk '{print $3, $4, $11}'
```

---

## Risk Mitigation

### Risk 1: Transcription Latency Too High
**Likelihood**: Medium
**Impact**: Medium
**Mitigation**:
- Start with base model (fastest with good accuracy)
- If latency still high, fall back to tiny model
- Consider GPU acceleration if available
- Measure actual latency and adjust expectations

### Risk 2: Package Incompatibility
**Likelihood**: Low
**Impact**: High
**Mitigation**:
- Validate Python version before installation
- Check portaudio is available in Arch repos
- Have fallback to HyprVoice or nerd-dictation ready
- Document exact package versions that work

### Risk 3: Microphone Access Issues
**Likelihood**: Low
**Impact**: High
**Mitigation**:
- Test microphone with pw-record before installation
- Verify PipeWire is working correctly
- Document troubleshooting steps for audio issues
- Check user permissions for audio group

### Risk 4: Service Doesn't Auto-Start
**Likelihood**: Low
**Impact**: Medium
**Mitigation**:
- Verify systemd user service is enabled
- Test reboot to confirm auto-start
- Add to Hyprland exec-once as fallback
- Document manual start command

---

## Completion Checklist

Before marking implementation complete, verify:

- [ ] Phase 1: Environment validated (microphone, Python, disk space)
- [ ] Phase 2: System dependencies installed (wtype, portaudio)
- [ ] Phase 3: faster-whisper-dictation installed via pip
- [ ] Phase 4: Systemd service file created
- [ ] Phase 5: Service started and enabled
- [ ] Phase 6: End-to-end testing passed
- [ ] Service auto-starts on system reboot
- [ ] Voice dictation works in terminal
- [ ] Voice dictation works in browser
- [ ] Voice dictation works in text editor
- [ ] Transcription accuracy is acceptable (>95%)
- [ ] Latency is acceptable (<500ms average)
- [ ] No errors in service logs
- [ ] No network traffic during usage (verified offline operation)
- [ ] Rollback plan tested (know how to revert if needed)
- [ ] Documentation updated with results

---

## Timeline Estimate

**Total Time**: ~1 hour (first-time setup with model download)

| Phase | Estimated Time | Notes |
|-------|---------------|-------|
| Phase 1: Validation | 5 minutes | Quick checks |
| Phase 2: System Deps | 5 minutes | Package installation |
| Phase 3: Install Package | 10 minutes | Python package install |
| Phase 4: Create Service | 5 minutes | File creation |
| Phase 5: Start Service | 20 minutes | Includes model download (142MB) |
| Phase 6: Testing | 15 minutes | Multiple test scenarios |
| **Total** | **60 minutes** | Plus optional enhancements |

**Subsequent Startups**: < 1 second (model already cached)

---

## Next Steps After Implementation

Once implementation is complete and validated:

1. **Use it!** Start using voice dictation in daily workflow
2. **Gather feedback** Note accuracy issues, latency problems, or use cases where it doesn't work well
3. **Optimize** Adjust model size or settings based on actual usage
4. **Document learnings** Update research doc with real-world results
5. **Consider enhancements** Implement optional features if needed

**Implementation Command**: `/start:implement 003`
