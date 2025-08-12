# YouTube Music Downloader Pro (Flutter)

A modern Flutter app that mirrors the original Python app's features:

- Paste a YouTube video or playlist URL
- Choose an output folder
- Download highest bitrate audio
- Convert to MP3 (320kbps) using FFmpeg when available
- Realtime progress, speed, ETA, and logs
- Stop/cancel in-progress downloads

## Run

Supported platforms: Android, Linux, Windows, macOS. (Web works for download only; no FFmpeg conversion.)

```bash
flutter pub get
flutter run -d linux   # or android, windows, macos
```

## Notes

- Real transcoding uses `ffmpeg_kit_flutter_min`. If conversion fails, the app falls back to copying the original audio to `.mp3`.
- On Android, minSdk is set to 24.
