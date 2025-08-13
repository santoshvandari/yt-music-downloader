#!/usr/bin/env bash
set -euo pipefail

APP_BIN="yt_music_flutter"
# Remove symlink if exists (packager already does this, but keep as a safeguard)
if [ -L "/usr/bin/$APP_BIN" ]; then
  rm -f "/usr/bin/$APP_BIN" || true
fi

# Update desktop database if available
if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database || true
fi

echo "YT Music Downloader post-uninstall completed."
