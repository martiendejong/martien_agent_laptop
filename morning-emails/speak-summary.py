#!/usr/bin/env python3
"""
Morning Email Briefing - TTS Engine
Uses edge-tts for natural speech synthesis
"""

import asyncio
import sys
import os
from pathlib import Path

try:
    import edge_tts
    EDGE_TTS_AVAILABLE = True
except ImportError:
    EDGE_TTS_AVAILABLE = False
    print("edge-tts not installed. Install with: pip install edge-tts")

# Configuration
VOICE = "en-US-AriaNeural"  # Siri-like voice
RATE = "+0%"  # Normal speed
VOLUME = "+0%"  # Normal volume

async def speak_with_edge_tts(text: str, output_file: str = None):
    """
    Speak text using edge-tts

    Args:
        text: Text to speak
        output_file: Optional path to save audio file
    """
    communicate = edge_tts.Communicate(text, VOICE, rate=RATE, volume=VOLUME)

    if output_file:
        # Save to file
        await communicate.save(output_file)
        print(f"Audio saved to {output_file}")
    else:
        # Stream directly (if mpv or similar player available)
        temp_file = Path(__file__).parent / "temp_speech.mp3"
        await communicate.save(str(temp_file))

        # Try to play with available players
        players = ["mpv", "ffplay", "powershell"]

        for player in players:
            try:
                if player == "powershell":
                    # Use Windows Media Player via PowerShell
                    os.system(f'powershell -c "(New-Object Media.SoundPlayer \\"{temp_file}\\").PlaySync()"')
                else:
                    os.system(f'{player} "{temp_file}"')
                break
            except:
                continue

        # Clean up temp file
        if temp_file.exists():
            temp_file.unlink()

def speak_with_windows_tts(text: str):
    """
    Fallback: Use Windows System.Speech TTS

    Args:
        text: Text to speak
    """
    # Create PowerShell script to use System.Speech
    ps_script = f"""
Add-Type -AssemblyName System.Speech
$speak = New-Object System.Speech.Synthesis.SpeechSynthesizer
$speak.Rate = 0
$speak.Volume = 100
$speak.Speak(@"
{text}
"@)
"""

    # Save to temp file and execute
    temp_ps = Path(__file__).parent / "temp_speak.ps1"
    temp_ps.write_text(ps_script, encoding='utf-8')

    try:
        os.system(f'powershell -ExecutionPolicy Bypass -File "{temp_ps}"')
    finally:
        if temp_ps.exists():
            temp_ps.unlink()

def main():
    """Main execution"""
    script_dir = Path(__file__).parent
    summary_file = script_dir / "summary.txt"

    if not summary_file.exists():
        print(f"Summary file not found: {summary_file}")
        sys.exit(1)

    text = summary_file.read_text(encoding='utf-8')

    if not text.strip():
        print("Summary file is empty")
        sys.exit(1)

    print(f"Speaking summary ({len(text)} characters)...")

    # Try edge-tts first, fallback to Windows TTS
    if EDGE_TTS_AVAILABLE:
        try:
            asyncio.run(speak_with_edge_tts(text))
            print("✓ Spoke using edge-tts (en-US-AriaNeural)")
        except Exception as e:
            print(f"edge-tts failed: {e}")
            print("Falling back to Windows System.Speech...")
            speak_with_windows_tts(text)
    else:
        print("Using Windows System.Speech TTS (edge-tts not available)")
        speak_with_windows_tts(text)

if __name__ == "__main__":
    main()
