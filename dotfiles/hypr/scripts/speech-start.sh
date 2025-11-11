#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════
# Speech-to-Text START (Key Press Handler)
# Starts recording when CMD+M is pressed
# ═══════════════════════════════════════════════════════════════════════════

SOCKET_PATH="/tmp/speech-to-text.sock"
BEEP_START="/home/miro/faster-whisper-dictation/assets/granted-04.wav"
NOTIFICATION_ID=9876  # Fixed ID to allow replacing/dismissing

# Check if daemon is running
if [ ! -S "$SOCKET_PATH" ]; then
    notify-send "🎤 Speech-to-Text" "❌ Daemon not running!" -t 3000 -u critical
    exit 1
fi

# Play start beep
paplay "$BEEP_START" 2>/dev/null &

# Show persistent notification (will stay until dismissed)
notify-send "🎙️ Recording..." "Hold CMD+M and speak. Release when done." \
    -t 0 -u normal -r "$NOTIFICATION_ID" &

# Send START command to daemon
RESPONSE=$(python3 -c "
import socket
sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
sock.connect('$SOCKET_PATH')
sock.sendall(b'START')
sock.shutdown(socket.SHUT_WR)
data = sock.recv(1024)
sock.close()
print(data.decode('utf-8'))
")

# Check if recording started successfully
if [[ "$RESPONSE" != "RECORDING_STARTED" ]]; then
    notify-send "🎤 Speech-to-Text" "❌ Failed to start recording" -t 3000 -u critical -r "$NOTIFICATION_ID"
    exit 1
fi
