#!/usr/bin/env python3
"""
Speech-to-Text Daemon with Hold-to-Record Support
Keeps Whisper model loaded in memory for instant transcription
Supports START/STOP commands for push-to-talk recording
"""

import socket
import os
import sys
import tempfile
import subprocess
import signal
import time
from pathlib import Path
import threading

# Add faster-whisper venv to path
sys.path.insert(0, '/home/miro/faster-whisper-dictation/venv/lib/python3.13/site-packages')

from faster_whisper import WhisperModel

SOCKET_PATH = "/tmp/speech-to-text.sock"
MIN_RECORDING_DURATION = 0.5  # seconds - minimum recording length

class SpeechDaemon:
    def __init__(self, model_size="base", device="cpu", compute_type="int8"):
        print(f"Loading Whisper model '{model_size}'...", flush=True)
        self.model = WhisperModel(model_size, device=device, compute_type=compute_type)
        print("Model loaded! Ready for transcription.", flush=True)

        # Recording state
        self.recording_proc = None
        self.recording_file = None
        self.recording_start_time = None
        self.state_lock = threading.Lock()

    def start_recording(self):
        """Start recording audio in background"""
        with self.state_lock:
            # If already recording, ignore
            if self.recording_proc is not None:
                return "ALREADY_RECORDING"

            # Create temp file for recording
            temp_file = tempfile.NamedTemporaryFile(suffix='.wav', delete=False)
            self.recording_file = temp_file.name
            temp_file.close()

            # Start recording process (explicitly use built-in mic)
            self.recording_proc = subprocess.Popen([
                'pw-record',
                '--target=alsa_input.pci-0000_02_00.3.BuiltinMic',
                '--rate=16000',
                '--format=s16',
                '--channels=1',
                self.recording_file
            ], stdout=subprocess.PIPE, stderr=subprocess.PIPE)

            self.recording_start_time = time.time()
            print(f"Recording started: {self.recording_file}", flush=True)
            return "RECORDING_STARTED"

    def stop_recording(self):
        """Stop recording and return audio file path"""
        with self.state_lock:
            # If not recording, return error
            if self.recording_proc is None:
                return None, "NOT_RECORDING"

            # Calculate recording duration
            duration = time.time() - self.recording_start_time

            # Stop recording gracefully
            self.recording_proc.send_signal(signal.SIGINT)
            try:
                self.recording_proc.wait(timeout=2)
            except subprocess.TimeoutExpired:
                self.recording_proc.kill()
                self.recording_proc.wait()

            audio_file = self.recording_file

            # Reset state
            self.recording_proc = None
            self.recording_file = None
            self.recording_start_time = None

            print(f"Recording stopped: {audio_file} ({duration:.2f}s)", flush=True)

            # Check if recording is too short
            if duration < MIN_RECORDING_DURATION:
                # Cleanup
                try:
                    os.remove(audio_file)
                except:
                    pass
                return None, "TOO_SHORT"

            # Check if file exists and has content
            if not os.path.exists(audio_file) or os.path.getsize(audio_file) < 1000:
                # Cleanup
                try:
                    os.remove(audio_file)
                except:
                    pass
                return None, "NO_AUDIO"

            return audio_file, "OK"

    def transcribe(self, audio_path):
        """Transcribe audio file using loaded model"""
        try:
            segments, info = self.model.transcribe(audio_path, beam_size=5)
            text = " ".join([segment.text for segment in segments])
            return text.strip()
        except Exception as e:
            print(f"Transcription error: {e}", flush=True)
            return None

    def handle_request(self, command):
        """Handle START or STOP command"""
        command = command.strip().upper()

        if command == "START":
            result = self.start_recording()
            return result

        elif command == "STOP":
            # Stop recording
            audio_file, status = self.stop_recording()

            if status != "OK":
                return f"ERROR:{status}"

            # Transcribe
            print("Transcribing...", flush=True)
            text = self.transcribe(audio_file)

            # Cleanup audio file
            try:
                os.remove(audio_file)
                print(f"Cleaned up: {audio_file}", flush=True)
            except Exception as e:
                print(f"Cleanup error: {e}", flush=True)

            # Return result
            if not text or text.strip() == "":
                return "ERROR:NO_SPEECH"

            return text

        else:
            return "ERROR:INVALID_COMMAND"

    def cleanup_on_shutdown(self):
        """Cleanup any ongoing recording on shutdown"""
        with self.state_lock:
            if self.recording_proc:
                self.recording_proc.kill()
                self.recording_proc.wait()

            if self.recording_file and os.path.exists(self.recording_file):
                try:
                    os.remove(self.recording_file)
                except:
                    pass

    def run(self):
        """Run the daemon socket server"""
        # Remove old socket if exists
        try:
            os.remove(SOCKET_PATH)
        except OSError:
            pass

        # Create Unix socket
        sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        sock.bind(SOCKET_PATH)
        sock.listen(5)

        print(f"Listening on {SOCKET_PATH}", flush=True)

        try:
            while True:
                connection, client_address = sock.accept()
                try:
                    # Receive command
                    data = connection.recv(1024)
                    command = data.decode('utf-8').strip()

                    # Handle request
                    result = self.handle_request(command)

                    # Send response
                    connection.sendall(result.encode('utf-8'))
                except Exception as e:
                    print(f"Error handling request: {e}", flush=True)
                    try:
                        connection.sendall(f"ERROR:EXCEPTION".encode('utf-8'))
                    except:
                        pass
                finally:
                    connection.close()
        except KeyboardInterrupt:
            print("\nShutting down...", flush=True)
        finally:
            self.cleanup_on_shutdown()
            sock.close()
            try:
                os.remove(SOCKET_PATH)
            except:
                pass

if __name__ == "__main__":
    daemon = SpeechDaemon()
    daemon.run()
