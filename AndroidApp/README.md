
# YT Music Downloader

YT Music Downloader is a modern Flutter app that lets you easily download high-quality audio from YouTube videos and playlists. It supports multiple platforms and provides a simple, fast, and reliable experience.

## Features

- Paste a YouTube video or playlist URL
- Choose an output folder
- Download highest bitrate audio
- Convert to MP3 (320kbps) using FFmpeg (when available)
- Realtime progress, speed, ETA, and logs
- Stop/cancel in-progress downloads

## Supported Platforms

- **Android**
- **Linux**
- **Windows**
- **iOS**

## Build & Run Instructions

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- [FFmpeg](https://ffmpeg.org/download.html) (optional, for best audio conversion)

### Common Steps
```bash
flutter pub get
```

### Linux
```bash
flutter run -d linux
```
Or build a release binary:
```bash
flutter build linux
```
```bash
dart pub global activate flutter_distributor
```
```bash
flutter_distributor package --platform linux --targets deb
```
Note: please change the `installed_size` in `make_config.yaml` to match the actual size of your application. Use the command `du -sk build/linux/x64/release/bundle | awk '{print $1}'` to get the size in kilobytes.


### Windows
```bash
flutter run -d windows
```
Or build a release binary:
```bash
flutter build windows
```

### Android
```bash
flutter run -d android
```
Or build an APK:
```bash
flutter build apk
```

### iOS
```bash
flutter run -d ios
```
Or build for release:
```bash
flutter build ios
```
> Note: iOS builds require a Mac with Xcode installed.

## Notes
- Real transcoding uses `ffmpeg_kit_flutter_min`. If conversion fails, the app falls back to copying the original audio to `.mp3`.
- On Android, minSdk is set to 24.
- The app name is "YT Music Downloader" across all platforms.

## License
This project is for educational and personal use only. Please respect YouTube's terms of service.
