# YouTube Music Downloader Pro

A modern, cross-platform application for downloading YouTube videos and playlists with high-quality MP3 audio extraction. Features both a sleek GUI interface and a command-line version for different user preferences.

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Python](https://img.shields.io/badge/python-3.8+-green.svg)
![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20macOS%20%7C%20Linux-lightgrey.svg)

> **⚠️ Disclaimer**: This tool is intended for educational and personal use only. Downloading copyrighted material without permission may violate YouTube's Terms of Service and copyright laws. Please respect content creators' rights.

## Features

### 🖥️ GUI Version
- **Modern Dark Theme**: Sleek, professional interface with smooth animations
- **Real-time Progress**: Live download progress with speed and ETA indicators
- **Batch Downloads**: Support for entire playlists with queue management
- **Smart URL Validation**: Real-time URL validation with helpful feedback
- **Activity Logging**: Detailed log of all download activities
- **Stop/Resume**: Ability to stop downloads mid-process with cleanup
- **Folder Selection**: Easy output folder selection with browse dialog

### CLI Version
- **Lightweight**: Fast command-line interface for power users
- **Batch Processing**: Efficient playlist processing
- **Simple Usage**: Straightforward prompts for URL and output folder

### Audio Processing
- **High Quality**: 320kbps MP3 conversion using FFmpeg
- **Format Support**: Converts from various YouTube audio formats
- **Metadata Preservation**: Maintains video title in filename
- **Automatic Cleanup**: Removes temporary files after conversion

## Quick Start

### Windows Users (Recommended)

1. Download the latest executable from [Releases](../../releases)
2. Run `YouTubeMusicDownloader.exe`
3. No installation required!

### Run from Source

#### Prerequisites
- Python 3.9 or higher
- Install necessary dependencies using `pip install -r requirements.txt`

#### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/santoshvandari/yt-music-downloader.git
   cd yt-music-downloader
   ```

2. **Create virtual environment**
   ```bash
   python -m venv venv
   
   # On Windows
   venv\Scripts\activate
   
   # On macOS/Linux
   source venv/bin/activate
   ```

3. **Install dependencies**
   ```bash
   pip install -r requirements.txt
   ```

4. **Run the application**
   ```bash
   # GUI version (recommended)
   python src/gui_main.py
   
   # CLI version
   python src/cli_main.py
   ```

## Usage Guide

### GUI Interface

1. **Launch the application** - Run the executable or Python script
2. **Enter YouTube URL** - Paste a video or playlist URL
3. **Select output folder** - Choose where to save your MP3 files
4. **Start download** - Click the download button and monitor progress
5. **Manage downloads** - Use the stop button if needed

### Command Line Interface

```bash
python src/cli_main.py
```

Follow the prompts to:
- Enter YouTube URL (video or playlist)
- Specify output folder (or use default)
- Watch the download progress

### Supported URLs

- **Single Videos**: `https://www.youtube.com/watch?v=VIDEO_ID`
- **Playlists**: `https://www.youtube.com/playlist?list=PLAYLIST_ID`
- **Short URLs**: `https://youtu.be/VIDEO_ID`
- **Mobile URLs**: `https://m.youtube.com/watch?v=VIDEO_ID`

## Building from Source

### Windows Executable

To create a standalone Windows executable:

```bash
cd packaging/windows
build.bat
```

The executable will be created in `dist/main.exe`
Note: use the inno setup script for a proper installer and final packaging.

### Custom Build

For advanced users wanting to customize the build:

```bash
pyinstaller --onefile --windowed --icon=assets/icon.png src/gui_main.py
```

## Project Structure

```
youtubevideodownloader/
├── 📁 src/                     # Source code
│   ├── 🐍 gui_main.py          # GUI application (main)
│   └── 🐍 cli_main.py          # Command-line interface
├── 📁 assets/                  # Application resources
│   ├── 🖼️ icon.png             # Application icon
│   └── 🖼️ logo.jpeg            # Logo image
├── 📁 packaging/               # Build configurations
│   └── 📁 windows/             # Windows-specific build
│       ├── 🦇 build.bat        # Build script
│       └── 🖼️ logo.ico         # Windows icon
├── 📁 download/                # Default download folder
├── 📄 requirements.txt         # Python dependencies
├── 📄 README.md                # This file
├── 📄 CODE_OF_CONDUCT.md       # Community guidelines
├── 📄 CONTRIBUTING.md          # Contribution guide
└── 📄 .gitignore               # Git ignore rules
```

## Dependencies

### Core Dependencies
- **pytubefix**: YouTube video/audio downloading
- **moviepy**: Audio conversion and processing
- **tkinter**: GUI framework (included with Python)

### Development Dependencies
- **PyInstaller**: Executable packaging


## Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details on:
- How to submit bug reports
- How to suggest new features
- Code style guidelines
- Pull request process

## Code of Conduct
Please read our [Code of Conduct](CODE_OF_CONDUCT.md) to understand the expected behavior in our community. We strive to create a welcoming and inclusive environment for all contributors.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- **pytubefix** - YouTube downloading library
- **moviepy** - Video/audio processing
- **YouTube** - For providing the content platform

## Legal Notice

This software is provided for educational and personal use only. Users are responsible for complying with:
- YouTube's Terms of Service
- Local copyright laws
- Content creators' rights
- Applicable licensing agreements

**The developers do not encourage or condone the downloading of copyrighted material without proper authorization.**

##  Support

- **Bug Reports**: [Open an issue](../../issues)
- **Feature Requests**: [Start a discussion](../../discussions)
- **Documentation**: Check this README and inline comments
- **Community**: [GitHub Discussions](../../discussions)

---

<div align="center">

**Made with ❤️ for the YouTube community**

⭐ Star this repo if you found it helpful!

</div>