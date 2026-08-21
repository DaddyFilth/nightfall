import math
import os
import struct
import wave


SAMPLE_RATE = 44100
OUTPUT_DIR = os.path.join(os.path.dirname(__file__), "..", "assets", "audio")


def write_tone(filename, duration, layers):
    frame_count = int(SAMPLE_RATE * duration)
    frames = bytearray()
    for index in range(frame_count):
        time = index / SAMPLE_RATE
        envelope = min(1.0, time / 0.012) * max(0.0, 1.0 - time / duration) ** 1.9
        sample = sum(amplitude * math.sin(2.0 * math.pi * frequency * time) for frequency, amplitude in layers)
        value = max(-1.0, min(1.0, sample * envelope))
        frames.extend(struct.pack("<h", int(value * 32767)))
    with wave.open(os.path.join(OUTPUT_DIR, filename), "wb") as output:
        output.setnchannels(1)
        output.setsampwidth(2)
        output.setframerate(SAMPLE_RATE)
        output.writeframes(bytes(frames))


os.makedirs(OUTPUT_DIR, exist_ok=True)
write_tone("ui-command-select.wav", 0.16, [(740, 0.18), (1110, 0.11), (1480, 0.05)])
write_tone("ui-deploy-confirm.wav", 0.34, [(92, 0.22), (138, 0.14), (696, 0.04)])
write_tone("ui-route-locked.wav", 0.22, [(196, 0.16), (247, 0.08)])
