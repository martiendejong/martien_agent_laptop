#!/usr/bin/env python3
"""
Meeting Transcription & Minutes Generator
Uses OpenAI Whisper for local speech-to-text transcription
"""

import whisper
import json
import sys
import os
from pathlib import Path
from datetime import datetime, timedelta

def format_timestamp(seconds):
    """Convert seconds to MM:SS format"""
    minutes = int(seconds // 60)
    secs = int(seconds % 60)
    return f"[{minutes:02d}:{secs:02d}]"

def generate_minutes(audio_file, model_size="base", output_dir=None):
    """
    Transcribe audio and generate meeting minutes

    Args:
        audio_file: Path to audio file
        model_size: Whisper model size (tiny, base, small, medium, large)
        output_dir: Output directory (default: same as audio file)
    """
    audio_path = Path(audio_file)

    if not audio_path.exists():
        print(f"Error: Audio file not found: {audio_file}")
        sys.exit(1)

    # Determine output directory
    if output_dir is None:
        output_dir = audio_path.parent
    else:
        output_dir = Path(output_dir)

    output_dir.mkdir(parents=True, exist_ok=True)

    # Output file paths
    base_name = audio_path.stem
    transcript_txt = output_dir / f"{base_name}-transcript.txt"
    transcript_json = output_dir / f"{base_name}-transcript.json"
    minutes_md = output_dir / f"{base_name}-minutes.md"

    print(f"\n{'='*70}")
    print(f"MEETING TRANSCRIPTION & MINUTES GENERATOR")
    print(f"{'='*70}\n")
    print(f"Audio file: {audio_path}")
    print(f"Model size: {model_size}")
    print(f"Output directory: {output_dir}\n")

    # Load Whisper model
    print(f"Loading Whisper model '{model_size}'...")
    model = whisper.load_model(model_size)
    print("✓ Model loaded\n")

    # Transcribe
    print("Transcribing audio (this may take a few minutes)...")
    result = model.transcribe(
        str(audio_path),
        verbose=False,
        language="en",  # Change if needed
        task="transcribe"
    )
    print("✓ Transcription complete\n")

    # Extract data
    full_text = result["text"]
    segments = result["segments"]

    # Get audio duration
    duration_seconds = segments[-1]["end"] if segments else 0
    duration = str(timedelta(seconds=int(duration_seconds)))

    # Save plain text transcript
    print(f"Saving plain transcript: {transcript_txt}")
    with open(transcript_txt, "w", encoding="utf-8") as f:
        f.write(full_text)

    # Save JSON transcript with timestamps
    print(f"Saving JSON transcript: {transcript_json}")
    with open(transcript_json, "w", encoding="utf-8") as f:
        json.dump({
            "audio_file": str(audio_path),
            "duration": duration,
            "language": result.get("language", "en"),
            "text": full_text,
            "segments": [
                {
                    "start": seg["start"],
                    "end": seg["end"],
                    "text": seg["text"].strip(),
                    "timestamp": format_timestamp(seg["start"])
                }
                for seg in segments
            ]
        }, f, indent=2, ensure_ascii=False)

    # Generate meeting minutes
    print(f"Generating meeting minutes: {minutes_md}")

    with open(minutes_md, "w", encoding="utf-8") as f:
        # Header
        f.write(f"# Meeting Minutes\n\n")
        f.write(f"**Date:** {datetime.now().strftime('%Y-%m-%d %H:%M')}\n")
        f.write(f"**Duration:** {duration}\n")
        f.write(f"**Source:** {audio_path.name}\n\n")

        f.write(f"---\n\n")

        # Summary section
        f.write(f"## Summary\n\n")
        f.write(f"{full_text}\n\n")

        f.write(f"---\n\n")

        # Full transcript with timestamps
        f.write(f"## Full Transcript\n\n")

        for seg in segments:
            timestamp = format_timestamp(seg["start"])
            text = seg["text"].strip()
            f.write(f"**{timestamp}** {text}\n\n")

        f.write(f"---\n\n")

        # Action items section (template)
        f.write(f"## Key Points & Action Items\n\n")
        f.write(f"*Review the transcript above and fill in key points and action items here.*\n\n")
        f.write(f"- [ ] Action item 1\n")
        f.write(f"- [ ] Action item 2\n")
        f.write(f"- [ ] Action item 3\n\n")

    print("\n" + "="*70)
    print("GENERATION COMPLETE")
    print("="*70)
    print(f"\nOutput files:")
    print(f"  - {minutes_md} (meeting minutes)")
    print(f"  - {transcript_txt} (plain text)")
    print(f"  - {transcript_json} (timestamped segments)")
    print(f"\nOpen the minutes file to review and edit.")

if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="Transcribe meeting audio and generate minutes")
    parser.add_argument("audio_file", help="Path to audio file (mp3, wav, etc.)")
    parser.add_argument(
        "-m", "--model",
        default="base",
        choices=["tiny", "base", "small", "medium", "large"],
        help="Whisper model size (default: base)"
    )
    parser.add_argument(
        "-o", "--output",
        help="Output directory (default: same as audio file)"
    )

    args = parser.parse_args()

    try:
        generate_minutes(args.audio_file, args.model, args.output)
    except KeyboardInterrupt:
        print("\n\nInterrupted by user")
        sys.exit(1)
    except Exception as e:
        print(f"\nError: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
