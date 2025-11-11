#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════
# Speech-to-Text STOP (Key Release Handler)
# Stops recording and transcribes when CMD+M is released
# ═══════════════════════════════════════════════════════════════════════════

SOCKET_PATH="/tmp/speech-to-text.sock"
BEEP_END="/home/miro/faster-whisper-dictation/assets/beepbeep.wav"
NOTIFICATION_ID=9876  # Same ID as start script to replace notification

# Check if daemon is running
if [ ! -S "$SOCKET_PATH" ]; then
    notify-send "🎤 Speech-to-Text" "❌ Daemon not running!" -t 3000 -u critical -r "$NOTIFICATION_ID"
    exit 1
fi

# Update notification to show processing
notify-send "✨ Transcribing..." "Processing your speech..." \
    -t 0 -u normal -r "$NOTIFICATION_ID" &

# Send STOP command to daemon and get transcription
RESPONSE=$(python3 -c "
import socket
sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
sock.connect('$SOCKET_PATH')
sock.sendall(b'STOP')
sock.shutdown(socket.SHUT_WR)
data = sock.recv(4096)
sock.close()
print(data.decode('utf-8'))
")

# Play end beep
paplay "$BEEP_END" 2>/dev/null &

# Handle errors
if [[ "$RESPONSE" == ERROR:* ]]; then
    ERROR_TYPE="${RESPONSE#ERROR:}"

    case "$ERROR_TYPE" in
        TOO_SHORT)
            notify-send "🎤 Speech-to-Text" "⚠️ Recording too short (min 0.5s)" \
                -t 3000 -u normal -r "$NOTIFICATION_ID"
            ;;
        NO_AUDIO)
            notify-send "🎤 Speech-to-Text" "❌ No audio captured" \
                -t 3000 -u normal -r "$NOTIFICATION_ID"
            ;;
        NO_SPEECH)
            notify-send "🎤 Speech-to-Text" "❌ No speech detected" \
                -t 3000 -u normal -r "$NOTIFICATION_ID"
            ;;
        NOT_RECORDING)
            notify-send "🎤 Speech-to-Text" "❌ Was not recording" \
                -t 3000 -u normal -r "$NOTIFICATION_ID"
            ;;
        *)
            notify-send "🎤 Speech-to-Text" "❌ Error: $ERROR_TYPE" \
                -t 3000 -u critical -r "$NOTIFICATION_ID"
            ;;
    esac
    exit 1
fi

# Check if we got text
if [ -z "$RESPONSE" ]; then
    notify-send "🎤 Speech-to-Text" "❌ No transcription returned" \
        -t 3000 -u critical -r "$NOTIFICATION_ID"
    exit 1
fi

# Small delay to ensure wtype works from keybind
sleep 0.1

# Inject text (no trailing newline)
echo -n "$RESPONSE" | wtype -

# Success notification (truncate long text for display)
TRUNCATED="${RESPONSE:0:50}"
[ ${#RESPONSE} -gt 50 ] && TRUNCATED="${TRUNCATED}..."
notify-send "✅ Typed Successfully" "$TRUNCATED" \
    -t 2000 -u normal -r "$NOTIFICATION_ID"
