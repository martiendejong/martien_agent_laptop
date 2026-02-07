# Meeting Recorder & Auto-Minutes Generator

Automatically record meetings and generate transcribed minutes using OpenAI Whisper.

## Features

- ✅ Record audio from any meeting (Google Meet, Teams, Zoom, in-person)
- ✅ Local speech-to-text transcription (OpenAI Whisper)
- ✅ Automatic meeting minutes generation
- ✅ Timestamped transcripts
- ✅ Multiple output formats (Markdown, plain text, JSON)
- ✅ No cloud services required (runs 100% locally)
- ✅ Free and open source

## Prerequisites

1. **Python 3.10+** - [Download](https://www.python.org/downloads/)
2. **ffmpeg** - [Download](https://www.gyan.dev/ffmpeg/builds/)
3. **Working microphone**

## Quick Setup

```powershell
cd C:\scripts\meeting-minutes
.\setup.ps1
```

This will:
- Check Python version
- Install openai-whisper and dependencies
- Verify ffmpeg
- Create Recordings directory

## Usage

### Step 1: Start Recording

```powershell
.\start-recording.ps1
```

This will:
- Show available microphones
- Let you select one
- Start recording to `C:\Users\[YOU]\Recordings\meeting-YYYY-MM-DD-HHMM.mp3`

**The recording runs in the foreground. Keep the window open during your meeting.**

### Step 2: Have Your Meeting

The recording continues until you stop it. You can minimize the window but don't close it.

### Step 3: Stop & Generate Minutes

When the meeting ends, either:

**Option A:** Press `q` in the recording window, then run:
```powershell
.\stop-and-transcribe.ps1
```

**Option B:** In a new window, run:
```powershell
.\stop-and-transcribe.ps1
```

This will:
- Stop the recording
- Transcribe using Whisper
- Generate meeting minutes

### Step 4: Review Your Minutes

Files saved in `C:\Users\[YOU]\Recordings\`:
- `meeting-YYYY-MM-DD-HHMM-minutes.md` - Formatted meeting minutes
- `meeting-YYYY-MM-DD-HHMM-transcript.txt` - Plain text transcript
- `meeting-YYYY-MM-DD-HHMM-transcript.json` - Timestamped segments

The minutes file opens automatically when transcription completes.

## Whisper Models

Choose model size based on accuracy vs speed:

| Model | Speed | Accuracy | Use Case |
|-------|-------|----------|----------|
| `tiny` | Fastest | Basic | Quick tests, short meetings |
| `base` | Fast | Good | Default, balanced |
| `small` | Medium | Better | Important meetings |
| `medium` | Slow | Great | Critical meetings |
| `large` | Slowest | Best | Maximum accuracy |

**Default:** `base` (good balance)

**Change model:**
```powershell
.\stop-and-transcribe.ps1 -Model small
```

**Transcription time estimates:**
- `tiny`: ~2 minutes for 1 hour meeting
- `base`: ~5 minutes for 1 hour meeting
- `small`: ~10 minutes for 1 hour meeting

## Audio Quality Tips

### Capture Both Sides of Call

Enable **Stereo Mix** in Windows:

1. Right-click speaker icon → Sound settings
2. More sound settings → Recording tab
3. Right-click empty area → Show Disabled Devices
4. Right-click "Stereo Mix" → Enable
5. Use "Stereo Mix" as microphone when recording

This captures both your mic AND computer audio (other participants).

### Reduce Background Noise

- Use headphones (prevents echo)
- Close window, turn off fans
- Use a quality microphone
- Record in quiet room

## Advanced Usage

### List Available Microphones

```powershell
.\start-recording.ps1 -ListMicrophones
```

### Specify Microphone

```powershell
.\start-recording.ps1 -Microphone "Stereo Mix"
```

### Transcribe Existing Audio

```powershell
python transcribe.py "C:\path\to\audio.mp3"
```

### Change Output Directory

```powershell
python transcribe.py audio.mp3 --output "C:\path\to\output"
```

### Use Different Model

```powershell
python transcribe.py audio.mp3 --model small
```

### Stop Recording Without Transcribing

```powershell
.\stop-and-transcribe.ps1 -NoTranscribe
```

## Troubleshooting

### "ffmpeg not found"

Download from https://www.gyan.dev/ffmpeg/builds/ and:
- Extract to `C:\ffmpeg\`
- Add `C:\ffmpeg\bin` to PATH

Or place anywhere and `start-recording.ps1` will find it.

### "openai-whisper not installed"

```powershell
pip install openai-whisper
```

### "No microphones found"

Check Windows Sound settings → Recording tab → ensure microphone enabled.

### "Transcription too slow"

Use smaller model:
```powershell
.\stop-and-transcribe.ps1 -Model tiny
```

### "Can't hear other participants in recording"

Enable Stereo Mix (see Audio Quality Tips above).

### "Out of memory during transcription"

- Close other applications
- Use smaller model (`tiny` or `base`)
- Upgrade RAM if possible

## File Structure

```
C:\scripts\meeting-minutes\
├── transcribe.py              # Whisper transcription engine
├── start-recording.ps1        # Start recording
├── stop-and-transcribe.ps1    # Stop & transcribe
├── setup.ps1                  # Install dependencies
└── README.md                  # This file

C:\Users\[YOU]\Recordings\     # Output directory
├── meeting-2026-02-07-1400.mp3
├── meeting-2026-02-07-1400-minutes.md
├── meeting-2026-02-07-1400-transcript.txt
└── meeting-2026-02-07-1400-transcript.json
```

## Whisper Model Download

First time you run transcription, Whisper downloads the model (~140MB for `base`).

This only happens once. Subsequent transcriptions use the cached model.

Models stored in: `C:\Users\[YOU]\.cache\whisper\`

## Privacy & Security

- ✅ **100% local** - No data sent to cloud
- ✅ **No API keys** - Completely offline
- ✅ **Free** - No usage limits or costs
- ✅ **Open source** - Inspect the code anytime

## Examples

### Daily Standup (10 minutes)

```powershell
.\start-recording.ps1
# Have meeting
.\stop-and-transcribe.ps1 -Model tiny
# Minutes ready in ~1 minute
```

### Client Call (1 hour)

```powershell
.\start-recording.ps1 -Microphone "Stereo Mix"
# Have meeting
.\stop-and-transcribe.ps1 -Model base
# Minutes ready in ~5 minutes
```

### Board Meeting (2 hours)

```powershell
.\start-recording.ps1 -Microphone "Stereo Mix"
# Have meeting
.\stop-and-transcribe.ps1 -Model small
# Minutes ready in ~15-20 minutes
```

## Integration with Claude

The JSON transcript can be fed to Claude for:
- Action item extraction
- Summary generation
- Key decision identification
- Follow-up email drafting

Example:
```powershell
$transcript = Get-Content "meeting-2026-02-07-transcript.json" | ConvertFrom-Json
# Feed $transcript.text to Claude for analysis
```

## Credits

- **OpenAI Whisper** - State-of-the-art speech recognition
- **ffmpeg** - Audio recording and processing
- **Claude Code** - System implementation

---

**Created:** 2026-02-07
**Author:** Jengo (Claude Agent)
**License:** MIT
