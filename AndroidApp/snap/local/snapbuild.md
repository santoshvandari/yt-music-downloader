# YouTube Music Downloader - Snap Build Documentation

## Overview

This document provides complete instructions for building, testing, and publishing the YouTube Music Downloader as a snap package.

## Project Structure

```
AndroidApp/ (Flutter project root)
├── pubspec.yaml
├── snapcraft.yaml
├── build-snap.sh
├── build/linux/x64/release/bundle/
│   └── yt_music_flutter
├── snap/
│   ├── gui/
│   │   ├── yt_music_downloader.desktop
│   │   └── icon.png
│   └── local/
│       └── snapbuild.md (this file)
└── lib/
    └── main.dart
```

## Prerequisites

### System Requirements
- Ubuntu 20.04+ or compatible Linux distribution
- Flutter SDK installed
- Snapcraft installed
- At least 2GB free disk space

### Install Required Tools
```bash
# Install Flutter
sudo snap install flutter --classic

# Install Snapcraft
sudo snap install snapcraft --classic

# Enable Linux desktop support
flutter config --enable-linux-desktop
```

## Quick Build Process

### Automated Build (Recommended)
```bash
# Make script executable
chmod +x build-snap.sh

# Run the build script
./build-snap.sh
```

### Manual Build Process
```bash
# 1. Build Flutter app
flutter clean
flutter pub get
flutter build linux --release

# 2. Clean previous snap builds
snapcraft clean
rm -rf parts/ stage/ prime/ *.snap

# 3. Build snap package
snapcraft pack --destructive-mode

# 4. Install and test
sudo snap install --dangerous --devmode yt-music-downloader_*.snap
yt-music-downloader
```

## Configuration Files

### snapcraft.yaml
```yaml
name: yt-music-downloader
base: core22
version: '1.0.0'
summary: YouTube Music Downloader
description: A simple Flutter-based app for downloading YouTube Music tracks.
grade: stable
confinement: strict

apps:
  yt-music-downloader:
    command: bin/yt_music_flutter
    plugs:
      - desktop
      - x11
      - network
      - home

parts:
  yt-music-downloader:
    plugin: dump
    source: build/linux/x64/release/bundle
    source-type: local
    stage-packages:
      # GTK and Cairo dependencies
      - libgtk-3-0t64
      - libcairo-gobject2
      - libcairo2
      - libgdk-pixbuf-2.0-0
      # Pango text rendering
      - libpango-1.0-0
      - libpangocairo-1.0-0
      - libpangoft2-1.0-0
      # Font and text dependencies
      - libfontconfig1
      - libfribidi0
      - libharfbuzz0b
      - libdatrie1
      - libthai0
      - libgraphite2-3
      # X11 dependencies
      - libx11-6
      - libxau6
      - libxcomposite1
      - libxcursor1
      - libxdamage1
      - libxdmcp6
      - libxext6
      - libxfixes3
      - libxi6
      - libxinerama1
      - libxrandr2
      - libxrender1
      - libxcb1
      - libxcb-render0
      - libxcb-shm0
      - libxkbcommon0
      # Wayland dependencies
      - libwayland-client0
      - libwayland-cursor0
      - libwayland-egl1
      # Other dependencies
      - libepoxy0
      - libpixman-1-0
      - libjpeg-turbo8
      - libatk1.0-0t64
      - libatk-bridge2.0-0t64
      - libatspi2.0-0t64
    organize:
      '*': bin/
```

### Desktop Entry (snap/gui/yt_music_downloader.desktop)
```ini
[Desktop Entry]
Name=YouTube Music Downloader
Comment=Download YouTube Music tracks easily
Exec=yt-music-downloader
Icon=${SNAP}/meta/gui/icon.png
Terminal=false
Type=Application
Categories=AudioVideo;Audio;Utility;
StartupNotify=true
MimeType=text/uri-list;
```

## Testing

### Local Testing
```bash
# Install in development mode
sudo snap install --dangerous --devmode yt-music-downloader_*.snap

# Run the application
yt-music-downloader

# Check application menu
# Look for "YouTube Music Downloader" in your desktop environment

# View logs if issues occur
snap logs yt-music-downloader

# Remove when done testing
sudo snap remove yt-music-downloader
```

### Strict Confinement Testing
```bash
# Test in production mode (strict confinement)
sudo snap install --dangerous yt-music-downloader_*.snap

# Check permissions
snap connections yt-music-downloader

# If network issues occur
sudo snap connect yt-music-downloader:network
```

## Troubleshooting

### Common Issues and Solutions

#### Flutter Bundle Not Found
```bash
# Ensure Flutter build completed successfully
ls -la build/linux/x64/release/bundle/yt_music_flutter

# If missing, rebuild Flutter
flutter clean
flutter build linux --release
```

#### Permission Errors
```bash
# Fix ownership issues
sudo chown -R $USER:$USER ~/Desktop/yt-music-downloader/

# Remove build artifacts
rm -rf parts/ stage/ prime/ *.snap

# Clean and rebuild
snapcraft clean
snapcraft pack --destructive-mode
```

#### Missing Dependencies
```bash
# Check what libraries are needed
ldd build/linux/x64/release/bundle/yt_music_flutter

# Add missing libraries to stage-packages in snapcraft.yaml
```

#### App Won't Start
```bash
# Check snap logs
snap logs yt-music-downloader

# Test Flutter app directly
./build/linux/x64/release/bundle/yt_music_flutter

# Install in devmode for debugging
sudo snap install --dangerous --devmode yt-music-downloader_*.snap
```

### Build Warnings
The following warnings during build are normal and can be ignored:
- `unused library` warnings
- Library linter suggestions for optional dependencies

## Version Management

### Updating Version
1. Update version in `snapcraft.yaml`
2. Update version in `pubspec.yaml` (recommended)
3. Rebuild:
   ```bash
   flutter build linux --release
   snapcraft pack --destructive-mode
   ```

### Semantic Versioning
- Format: `MAJOR.MINOR.PATCH`
- Example: `1.0.0`, `1.0.1`, `1.1.0`

## Store Publication

### Prepare for Store
```bash
# Test in strict confinement
sudo snap install --dangerous yt-music-downloader_*.snap

# Ensure all features work without devmode
```

### Upload to Snap Store
```bash
# Login to Snapcraft
snapcraft login

# Register snap name (one-time)
snapcraft register yt-music-downloader

# Upload to edge channel for testing
snapcraft upload yt-music-downloader_*.snap --release=edge

# Test the edge release
sudo snap install yt-music-downloader --channel=edge

# Promote to stable when ready
snapcraft release yt-music-downloader 1 stable
```

## Development Workflow

### Daily Development Cycle
```bash
# Make code changes
# ... edit your Flutter code ...

# Quick rebuild and test
flutter build linux --release && snapcraft pack --destructive-mode
sudo snap remove yt-music-downloader 2>/dev/null || true
sudo snap install --dangerous --devmode yt-music-downloader_*.snap
yt-music-downloader
```

### Clean Build (when things go wrong)
```bash
# Nuclear option - clean everything
flutter clean
snapcraft clean
rm -rf parts/ stage/ prime/ *.snap
sudo snap remove yt-music-downloader 2>/dev/null || true

# Rebuild from scratch
flutter pub get
flutter build linux --release
snapcraft pack --destructive-mode
```

## Best Practices

### Before Building
- [ ] Test Flutter app directly: `./build/linux/x64/release/bundle/yt_music_flutter`
- [ ] Ensure icon.png exists (256x256 pixels minimum)
- [ ] Verify version numbers are updated
- [ ] Check that all required files are present

### Testing Checklist
- [ ] App launches successfully
- [ ] All features work as expected
- [ ] Network access works (if needed)
- [ ] File access works (if needed)
- [ ] App appears in desktop application menu
- [ ] Icon displays correctly

### Store Submission Checklist
- [ ] App works in strict confinement
- [ ] All plugs are necessary and justified
- [ ] App description is clear and accurate
- [ ] Screenshots and metadata prepared
- [ ] Version follows semantic versioning

## Key Commands Reference

```bash
# Essential build command
snapcraft pack --destructive-mode

# Full development cycle
flutter build linux --release && snapcraft pack --destructive-mode

# Install and test
sudo snap install --dangerous --devmode yt-music-downloader_*.snap

# Debug
snap logs yt-music-downloader

# Clean everything
flutter clean && snapcraft clean && rm -rf parts/ stage/ prime/ *.snap
```

## Notes

- Always use `--destructive-mode` for building to avoid container networking issues
- The `dump` plugin is sufficient for Flutter applications
- Minimal stage-packages work best to avoid dependency conflicts
- Test in both devmode and strict confinement before publishing
- Keep the icon at least 256x256 pixels for best results
