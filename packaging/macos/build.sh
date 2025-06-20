#!/bin/bash
pyinstaller --onefile --windowed --icon=icon.icns ../src/main.py
hdiutil create -volname "YT Music Downloader" -srcfolder dist/ -ov -format UDZO yt-music-downloader.dmg
echo "Build and DMG creation completed."
