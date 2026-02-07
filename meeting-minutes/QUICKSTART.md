# Meeting Recorder - Quick Start

Get recording and transcribing in 5 minutes.

## Installation

```powershell
cd C:\scripts\meeting-minutes
.\setup.ps1
```

## First Recording

### 1. Start Recording

```powershell
.\start-recording.ps1
```

Select your microphone when prompted.

### 2. Have Your Meeting

Keep the recording window open (you can minimize it).

### 3. Stop & Transcribe

```powershell
.\stop-and-transcribe.ps1
```

Wait a few minutes for transcription to complete.

### 4. Review Minutes

Your minutes file will open automatically:
`C:\Users\[YOU]\Recordings\meeting-YYYY-MM-DD-HHMM-minutes.md`

## That's It!

See `README.md` for:
- Audio quality tips
- Model selection
- Advanced features
- Troubleshooting

## Quick Commands

```powershell
# List microphones
.\start-recording.ps1 -ListMicrophones

# Start with specific mic
.\start-recording.ps1 -Microphone "Stereo Mix"

# Use better model (slower but more accurate)
.\stop-and-transcribe.ps1 -Model small

# Use faster model (less accurate but quick)
.\stop-and-transcribe.ps1 -Model tiny
```

## Recommended: Enable Stereo Mix

To capture both your voice AND other participants:

1. Right-click speaker icon → Sound settings
2. More sound settings → Recording tab
3. Right-click empty area → Show Disabled Devices
4. Right-click "Stereo Mix" → Enable
5. Select "Stereo Mix" when starting recording

This records everything your computer plays (Google Meet, Zoom, etc.)

---

**Full docs:** README.md
