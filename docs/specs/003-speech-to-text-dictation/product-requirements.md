# Product Requirements Document

## Validation Checklist

- [ ] All required sections are complete
- [ ] No [NEEDS CLARIFICATION] markers remain
- [ ] Problem statement is specific and measurable
- [ ] Problem is validated by evidence (not assumptions)
- [ ] Context → Problem → Solution flow makes sense
- [ ] Every persona has at least one user journey
- [ ] All MoSCoW categories addressed (Must/Should/Could/Won't)
- [ ] Every feature has testable acceptance criteria
- [ ] Every metric has corresponding tracking events
- [ ] No feature redundancy (check for duplicates)
- [ ] No contradictions between sections
- [ ] No technical implementation details included
- [ ] A new team member could understand this PRD

---

## Product Overview

### Vision
Enable hands-free text input anywhere on the system through voice dictation, matching the Wispr Flow experience on other platforms but with complete privacy and offline operation.

### Problem Statement
Users need to type text into various applications (terminal, browser, text editor, chat apps) but typing is slower than speaking and requires hands on keyboard. The preferred solution (Wispr Flow) doesn't support Linux. Current typing workflow limits productivity, especially for long-form content, documentation, and communication. Users on macOS/Windows enjoy seamless voice-to-text input through Wispr Flow, but this capability is missing on Arch Linux/Hyprland setups.

### Value Proposition
Unlike cloud-based solutions (Wispr Flow, Google Speech-to-Text), this provides 100% offline, privacy-respecting voice dictation with state-of-the-art accuracy using local Whisper models. Users get faster input than typing, no API costs, complete privacy, and native Wayland/Hyprland integration through a simple keyboard shortcut.

## User Personas

### Primary Persona: Technical Power User
- **Demographics:** Tech-savvy user running Arch Linux + Hyprland, values privacy and control, comfortable with terminal and configuration files
- **Goals:** Maximize productivity through efficient text input, maintain complete data privacy, use modern AI capabilities offline without cloud dependencies
- **Pain Points:** Typing is slower than speaking for long content; Wispr Flow (preferred solution) unavailable on Linux; cloud services compromise privacy; existing Linux solutions have poor accuracy or complex setup

### Secondary Personas
N/A - Single primary persona for this feature

## User Journey Maps

### Primary User Journey: Voice Dictation Adoption
1. **Awareness:** User experiences Wispr Flow on macOS, wants same capability on Linux; discovers typing is bottleneck for productivity
2. **Consideration:** Evaluates cloud APIs (privacy concerns, costs), existing Linux tools (poor accuracy, complex setup), decides offline Whisper-based solution is best fit
3. **Adoption:** Follows lightweight setup guide, installs faster-whisper-dictation, configures SUPER+M keybinding in Hyprland
4. **Usage:** Press SUPER+M, speak naturally, release key, transcribed text appears in focused application (browser, terminal, editor)
5. **Retention:** Fast transcription (200-500ms), high accuracy with proper punctuation/capitalization, works offline, respects privacy, becomes natural part of workflow

### Secondary User Journeys
N/A - Single primary journey for this feature

## Feature Requirements

### Must Have Features

#### Feature 1: Keyboard-Activated Voice Capture
- **User Story:** As a power user, I want to press SUPER+M to start voice recording so that I can dictate text hands-free
- **Acceptance Criteria:**
  - [ ] SUPER+M keybinding triggers voice recording in any focused application
  - [ ] Recording starts immediately when key is pressed
  - [ ] Visual/audio feedback indicates recording is active
  - [ ] Recording stops when key is released or after 10-second timeout
  - [ ] Works across all Wayland applications (native and XWayland)

#### Feature 2: High-Accuracy Offline Transcription
- **User Story:** As a privacy-conscious user, I want my speech transcribed locally with high accuracy so that my voice data never leaves my machine
- **Acceptance Criteria:**
  - [ ] Uses faster-whisper-dictation with Whisper base/small model
  - [ ] Transcription happens 100% offline (no internet required)
  - [ ] Transcription latency under 500ms on CPU (under 100ms with GPU)
  - [ ] Accuracy comparable to cloud services (proper capitalization, punctuation)
  - [ ] Handles technical terms, names, and natural speech patterns

#### Feature 3: Universal Text Injection
- **User Story:** As a user, I want transcribed text automatically typed into my focused application so that I don't need to manually paste
- **Acceptance Criteria:**
  - [ ] Transcribed text automatically injected into focused window
  - [ ] Works in terminal, browser, text editor, chat apps, and all user-level applications
  - [ ] Uses wtype for text injection (Wayland virtual keyboard protocol)
  - [ ] Text appears as if typed by user (no clipboard pollution)
  - [ ] Cannot inject into sudo prompts or lock screens (Wayland security)

### Should Have Features
- Desktop notifications showing transcription status and result
- GPU acceleration support for faster transcription (<100ms latency)
- Multiple Whisper model size options (tiny/base/small/medium)
- Configurable keybinding (not hardcoded to SUPER+M)

### Could Have Features
- Real-time transcription preview overlay
- Transcription history with undo capability
- Voice command mode (e.g., "new line", "delete last word")
- Multi-language support with automatic detection
- Integration with system clipboard as fallback

### Won't Have (This Phase)
- Cloud API integration (defeats privacy goal)
- Windows/macOS support (Linux-specific implementation)
- Continuous always-listening mode (security/privacy risk)
- Custom vocabulary training (use pretrained models only)
- Mobile device support
- Push-to-talk with dedicated hardware button

## Detailed Feature Specifications

### Feature: Keyboard-Activated Voice Capture & Transcription
**Description:** User presses and holds SUPER+M to record voice, releases to stop recording and trigger transcription. The system captures audio via PipeWire, transcribes using local Whisper model, and injects the result into the focused application.

**User Flow:**
1. User presses SUPER+M while focused on any text input (terminal, browser, editor)
2. System starts audio recording via PipeWire (pw-record at 16kHz mono)
3. System shows notification "Recording..." or audio feedback
4. User speaks their text naturally
5. User releases SUPER+M (or 10-second timeout occurs)
6. System stops recording, saves temporary audio file
7. System shows notification "Transcribing..."
8. faster-whisper-dictation transcribes audio locally (200-500ms)
9. System injects transcribed text via wtype into focused window
10. System shows notification with transcribed text
11. System cleans up temporary audio file

**Business Rules:**
- Rule 1: Recording must start within 100ms of key press for responsive feel
- Rule 2: Maximum recording duration is 10 seconds to prevent runaway recordings
- Rule 3: Audio files stored in /tmp and deleted immediately after transcription
- Rule 4: Transcription must complete within 1 second on modern CPU (2-3 years old)
- Rule 5: Text injection respects Wayland security (no injection into elevated contexts)
- Rule 6: SUPER+M keybinding must not conflict with existing Hyprland bindings
- Rule 7: Daemon must auto-start on login and run in background

**Edge Cases:**
- Scenario 1: User releases key immediately (< 0.5s recording) → Expected: Ignore/cancel, no transcription attempted
- Scenario 2: No speech detected in recording → Expected: Show notification "No speech detected", do not inject anything
- Scenario 3: Transcription fails or returns empty → Expected: Show error notification, do not inject anything
- Scenario 4: User presses SUPER+M while already recording → Expected: Stop current recording, start new one (or toggle behavior)
- Scenario 5: Microphone not available or permission denied → Expected: Show error notification with troubleshooting steps
- Scenario 6: Background noise causes poor transcription → Expected: Inject whatever was transcribed (user can undo/delete)
- Scenario 7: Very long recording (10+ seconds) → Expected: Auto-stop at 10 seconds, transcribe what was captured
- Scenario 8: Focus changes during recording → Expected: Continue recording, inject into window that had focus when SUPER+M was pressed
- Scenario 9: faster-whisper-dictation daemon not running → Expected: Show error notification "Speech-to-text service not running"

## Success Metrics

### Key Performance Indicators

- **Adoption:** User successfully completes setup and performs first voice dictation within 1 hour
- **Engagement:** User uses voice dictation at least 5 times per day after first week
- **Quality:** Transcription accuracy >95% (minimal manual corrections needed), latency <500ms average
- **Business Impact:** User reports 20%+ time savings on long-form text input (documentation, emails, chat)

### Tracking Requirements

This is a local-only feature with no telemetry. Success validation will be manual:

| Event | Properties | Purpose |
|-------|------------|---------|
| Setup completion | Installation time, model size chosen | Validate setup is under 1 hour |
| First successful dictation | Latency, transcription length | Validate basic functionality works |
| Daily usage pattern | Number of activations per day | Validate feature becomes part of workflow |
| Transcription quality | User-reported accuracy issues | Identify accuracy problems to address |

**Note:** No automatic tracking implemented to respect privacy. User provides feedback voluntarily.

---

## Constraints and Assumptions

### Constraints
- **Platform:** Linux only (Arch Linux with Hyprland/Wayland compositor)
- **Hardware:** Requires microphone, Intel/AMD CPU (MacBook Pro T2 in this case)
- **Dependencies:** PipeWire for audio (already installed), Python environment for faster-whisper-dictation
- **Timeline:** Setup and configuration should complete in 1-2 hours maximum
- **Resources:** Will consume ~150-500MB RAM for Whisper model, CPU cycles during transcription
- **Privacy:** 100% offline operation required (no cloud APIs), zero telemetry

### Assumptions
- User has working microphone and PipeWire audio system configured
- User is comfortable running yay/pip commands and editing Hyprland config
- User has ~2GB disk space for Whisper models and dependencies
- User accepts 200-500ms transcription latency as acceptable tradeoff for privacy
- faster-whisper-dictation package remains available and compatible with Arch Linux
- wtype works reliably with user's Hyprland version and applications

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| faster-whisper-dictation incompatible with Arch/Hyprland | High | Low | Validate compatibility before implementation; have fallback to nerd-dictation or HyprVoice |
| Transcription accuracy insufficient for production use | High | Medium | Test with various accents/speeds; allow model size selection (base/small/medium); document limitations |
| Latency too high on MacBook Pro T2 CPU | Medium | Medium | Start with base model (fastest); provide GPU acceleration option; benchmark actual latency early |
| wtype doesn't work with specific applications | Medium | Low | Test across multiple apps (terminal, browser, editor); have dotool as fallback input tool |
| Microphone permissions or PipeWire configuration issues | Medium | Medium | Document troubleshooting steps; validate microphone works with pw-record before setup |
| Daemon doesn't auto-start reliably | Low | Medium | Provide systemd user service unit; test on system reboot; document manual start command |
| SUPER+M keybinding conflicts with future additions | Low | Low | Document keybinding clearly; make it configurable in future enhancement |

## Open Questions

- [x] Which speech-to-text solution provides best accuracy/performance tradeoff? → **Decision: faster-whisper-dictation**
- [x] What keybinding won't conflict with existing Hyprland setup? → **Decision: SUPER+M (validated against existing config)**
- [x] Is Wispr Flow available on Linux? → **Answer: No, macOS/Windows/iOS only**
- [ ] Should we support both press-and-hold and toggle recording modes? → **Defer to implementation phase**
- [ ] What Whisper model size works best on MacBook Pro T2? → **Test during implementation (start with base)**
- [ ] Should notifications be mandatory or optional? → **Defer to user preference configuration**

---

## Supporting Research

### Competitive Analysis

**Wispr Flow (macOS/Windows/iOS):**
- Cloud-based, very low latency
- Excellent accuracy and user experience
- **Not available on Linux** - primary motivation for this feature
- Privacy concerns (audio sent to cloud)

**faster-whisper-dictation:**
- Local Whisper with 4x optimization
- 200-500ms latency (CPU), <100ms (GPU)
- Excellent accuracy, proper punctuation/capitalization
- **Selected as primary solution**

**Alternatives evaluated:**
- nerd-dictation (VOSK): Simpler but lower accuracy, lowercase-only
- HyprVoice: Ready-made solution, good fallback option
- whisper.cpp + custom scripts: Maximum performance but complex setup
- OpenAI Whisper API: Best accuracy but defeats privacy goal and costs money

**Full research:** docs/SPEECH_TO_TEXT_RESEARCH.md

### User Research

User (miro) explicitly requested:
- Wispr Flow equivalent for Linux
- Ability to trigger via keyboard shortcut
- Type into any text input
- Open to alternative tools/APIs if Wispr not possible

User priorities (inferred from request):
1. Privacy (uses Arch Linux + Hyprland, values control)
2. Convenience (loved Wispr Flow on other systems)
3. Integration (wants it to work seamlessly with existing setup)

### Market Data

**Linux desktop speech-to-text market:**
- Growing interest in offline AI capabilities
- Privacy-conscious users seeking alternatives to cloud services
- Whisper adoption increasing due to open-source + high accuracy
- Wayland transition creating need for new input tools (X11 tools don't work)

**Relevant trends:**
- Local LLM/AI inference becoming practical on consumer hardware
- Wayland security model requiring new approach to input simulation
- faster-whisper making real-time transcription viable on CPU
