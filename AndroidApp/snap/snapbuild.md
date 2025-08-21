# Complete Flutter to Snap Build Guide

## Prerequisites

### Install Required Tools
```bash
# Install Flutter (if not already installed)
sudo snap install flutter --classic

# Install Snapcraft
sudo snap install snapcraft --classic

# Install LXD (for clean builds)
sudo snap install lxd
sudo lxd init --auto
sudo usermod -a -G lxd $USER

# Install multipass (alternative to LXD)
sudo snap install multipass
```

**Important**: Log out and log back in after adding yourself to the lxd group.

## Step 1: Prepare Your Flutter Project

### 1.1 Navigate to Your Project
```bash
cd /path/to/your/yt-music-downloader-project
```

### 1.2 Clean Previous Builds
```bash
flutter clean
flutter pub get
```

### 1.3 Enable Linux Desktop Support
```bash
flutter config --enable-linux-desktop
```

## Step 2: Build Flutter Bundle for Linux

### 2.1 Build Release Bundle
```bash
# Build for Linux desktop
flutter build linux --release

# Verify the build was successful
ls -la build/linux/x64/release/bundle/
```

You should see:
- `yt_music_flutter` (your executable)
- `data/` directory
- `lib/` directory
- Other necessary files

### 2.2 Test Your Flutter App Locally
```bash
# Run the built executable to make sure it works
./build/linux/x64/release/bundle/yt_music_flutter
```

## Step 3: Create Snap Structure

### 3.1 Create Snap Directory Structure
```bash
mkdir -p snap/gui
```

### 3.2 Create snapcraft.yaml
Create `snapcraft.yaml` in your project root:

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
      - desktop-legacy
      - x11
      - wayland
      - network
      - network-bind
      - home
      - removable-media
      - gsettings
      - audio-playback
      - pulseaudio
    extensions:
      - gnome

parts:
  yt-music-downloader:
    plugin: dump
    source: build/linux/x64/release/bundle
    source-type: local
    stage-packages:
      - libgtk-3-0
      - libglib2.0-0
      - libgobject-2.0-0
      - libwayland-egl1
      - libxcb-render0
      - libxcb-shm0
      - libxcb1
      - libxkbcommon0
      - libegl1-mesa
      - libgl1-mesa-glx
      - libglu1-mesa
    organize:
      '*': bin/
    override-build: |
      craftctl default
      # Ensure executable permissions
      chmod +x $CRAFTCTL_PART_INSTALL/bin/yt_music_flutter

slots:
  yt-music-downloader:
    interface: dbus
    bus: session
    name: com.example.ytmusicdownloader
```

### 3.3 Create Desktop File
Create `snap/gui/yt_music_downloader.desktop`:

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

### 3.4 Add Icon
```bash
# Copy your app icon to the snap gui directory
cp path/to/your/icon.png snap/gui/icon.png

# If you don't have an icon, create a simple one or download one
# Make sure it's at least 256x256 pixels for best results
```

### 3.5 Verify Directory Structure
```bash
tree -a
```

Should look like:
```
your-project/
├── snapcraft.yaml
├── snap/
│   └── gui/
│       ├── yt_music_downloader.desktop
│       └── icon.png
├── build/
│   └── linux/
│       └── x64/
│           └── release/
│               └── bundle/
│                   ├── yt_music_flutter
│                   ├── data/
│                   └── lib/
└── (other Flutter project files)
```

## Step 4: Build the Snap

### 4.1 Clean Previous Snap Builds
```bash
snapcraft clean
```

### 4.2 Build the Snap
```bash
# Build using LXD (recommended for clean builds)
snapcraft --use-lxd

# Alternative: Build using Multipass
snapcraft --use-multipass

# Alternative: Build natively (may have dependency conflicts)
snapcraft
```

**Note**: The first build may take 10-20 minutes as it downloads base images.

### 4.3 Check Build Output
```bash
ls -la *.snap
```

You should see: `yt-music-downloader_1.0.0_amd64.snap`

## Step 5: Test the Snap Locally

### 5.1 Install in DevMode
```bash
# Install in devmode for testing (less restrictive)
sudo snap install --dangerous --devmode yt-music-downloader_1.0.0_amd64.snap
```

### 5.2 Test the Application
```bash
# Run from command line
yt-music-downloader

# Check if it appears in applications menu
# Look for "YouTube Music Downloader" in your desktop environment

# Check snap info
snap info yt-music-downloader

# Check logs if there are issues
snap logs yt-music-downloader
```

### 5.3 Test Different Confinement Modes
```bash
# Remove devmode version
sudo snap remove yt-music-downloader

# Install in strict mode (recommended for store)
sudo snap install --dangerous yt-music-downloader_1.0.0_amd64.snap

# If strict mode fails, check interfaces
snap connections yt-music-downloader
```

## Step 6: Debug Common Issues

### 6.1 Check Snap Interfaces
```bash
# List available interfaces
snap interface

# Connect specific interfaces if needed
sudo snap connect yt-music-downloader:network
sudo snap connect yt-music-downloader:home
```

### 6.2 Debug Permission Issues
```bash
# Check snap logs
journalctl -f | grep yt-music-downloader

# Check AppArmor denials
sudo dmesg | grep DENIED

# Run in devmode to bypass restrictions temporarily
sudo snap install --dangerous --devmode yt-music-downloader_1.0.0_amd64.snap
```

### 6.3 Debug Missing Libraries
```bash
# Check what libraries your app needs
ldd build/linux/x64/release/bundle/yt_music_flutter

# Add missing libraries to stage-packages in snapcraft.yaml
```

## Step 7: Iterate and Improve

### 7.1 Make Changes and Rebuild
```bash
# After making changes to snapcraft.yaml
snapcraft clean
snapcraft --use-lxd

# Reinstall
sudo snap remove yt-music-downloader
sudo snap install --dangerous yt-music-downloader_1.0.0_amd64.snap
```

### 7.2 Version Updates
```bash
# Update version in snapcraft.yaml, then rebuild
# Version format: 'major.minor.patch' or 'major.minor.patch-build'
```

## Step 8: Prepare for Store Publication

### 8.1 Test in Strict Confinement
```bash
# Make sure your app works in strict mode
sudo snap remove yt-music-downloader
sudo snap install --dangerous yt-music-downloader_1.0.0_amd64.snap
```

### 8.2 Create Store Account
```bash
# Register store account and login
snapcraft login

# Register your snap name (if available)
snapcraft register yt-music-downloader
```

### 8.3 Upload to Store
```bash
# Upload to edge channel for testing
snapcraft upload yt-music-downloader_1.0.0_amd64.snap --release=edge

# After testing, promote to stable
snapcraft release yt-music-downloader 1 stable
```

## Troubleshooting Common Issues

### Build Fails
- Check Flutter bundle exists: `ls build/linux/x64/release/bundle/`
- Verify snapcraft.yaml syntax: `snapcraft lint`
- Check LXD/Multipass status: `lxd version` or `multipass version`

### App Won't Start
- Check executable permissions in bundle
- Test Flutter app directly before snapping
- Review snap logs: `snap logs yt-music-downloader`

### Missing Icons or Desktop Integration
- Ensure icon.png exists in `snap/gui/`
- Check desktop file syntax
- Verify categories in desktop file

### Network/File Access Issues
- Add appropriate plugs to snapcraft.yaml
- Test in devmode first
- Check interface connections

This comprehensive guide should get your Flutter app successfully packaged and running as a snap!