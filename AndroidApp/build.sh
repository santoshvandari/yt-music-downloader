#!/bin/bash

# Flutter to Snap Build Script
# Usage: ./build-snap.sh

set -e  # Exit on any error

echo "🚀 Starting Flutter to Snap build process..."

# Step 1: Clean Flutter build
echo "🧹 Cleaning Flutter build..."
flutter clean
flutter pub get

# Step 2: Build Flutter for Linux
echo "🔨 Building Flutter app for Linux..."
flutter build linux --release

# Step 3: Verify Flutter bundle exists
if [ ! -f "build/linux/x64/release/bundle/yt_music_flutter" ]; then
    echo "❌ Error: Flutter bundle not found!"
    echo "Expected: build/linux/x64/release/bundle/yt_music_flutter"
    exit 1
fi
echo "✅ Flutter bundle found"

# Step 4: Clean any previous snap builds
echo "🧹 Cleaning previous snap builds..."
snapcraft clean
rm -rf parts/ stage/ prime/ *.snap

# Step 5: Create snapcraft.yaml if it doesn't exist
if [ ! -f "snapcraft.yaml" ]; then
    echo "📝 Creating snapcraft.yaml..."
    cat > snapcraft.yaml << 'EOF'
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
      - libgtk-3-0
      - libcairo2
      - libx11-6
    organize:
      '*': bin/
EOF
fi

# Step 6: Ensure snap/gui directory exists with required files
echo "📁 Setting up snap GUI files..."
mkdir -p snap/gui

# Create desktop file if it doesn't exist
if [ ! -f "snap/gui/yt_music_downloader.desktop" ]; then
    cat > snap/gui/yt_music_downloader.desktop << 'EOF'
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
EOF
fi

# Check for icon
if [ ! -f "snap/gui/icon.png" ]; then
    echo "⚠️  Warning: No icon found at snap/gui/icon.png"
    echo "   Please add your app icon there for better presentation"
fi

# Step 7: Build the snap
echo "📦 Building snap package..."
snapcraft pack --destructive-mode

# Step 8: Check if snap was created
SNAP_FILE=$(ls yt-music-downloader_*.snap 2>/dev/null | head -1)
if [ -f "$SNAP_FILE" ]; then
    echo "🎉 SUCCESS! Snap created: $SNAP_FILE"
    echo ""
    echo "📋 Next steps:"
    echo "1. Install for testing:"
    echo "   sudo snap install --dangerous --devmode $SNAP_FILE"
    echo ""
    echo "2. Run the app:"
    echo "   yt-music-downloader"
    echo ""
    echo "3. Check logs if issues occur:"
    echo "   snap logs yt-music-downloader"
    echo ""
    echo "4. Remove the snap:"
    echo "   sudo snap remove yt-music-downloader"
else
    echo "❌ Error: Snap file not found!"
    exit 1
fi

echo "✨ Build process completed!"