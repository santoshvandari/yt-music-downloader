# YT Music Downloader

A cross-platform GUI application for downloading YouTube videos and playlists, with high-quality MP3 audio extraction.

> **Disclaimer**: This tool is intended for educational and personal use only. Downloading copyrighted material without permission may violate YouTube's Terms of Service.

##Features

- Download individual YouTube videos or entire playlists
- Convert to high-quality `.mp3` audio using FFmpeg
- Clean and intuitive GUI built with Tkinter
- Lightweight application with no browser automation
- Pre-built Windows executable available

## Installation

### Windows Users

Download the pre-built executable from the [Releases](../../releases) page. No installation required - simply run the `.exe` file.

### Run from Source

#### Prerequisites

- Python 3.8 or higher
- FFmpeg (for audio conversion)

#### Setup Instructions

1. **Clone the repository**

   ```bash
   git clone https://github.com/YOUR_USERNAME/yt-music-downloader.git
   cd yt-music-downloader
   ```

2. **Create virtual environment**

   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. **Install dependencies**

   ```bash
   pip install -r requirements.txt
   ```

4. **Run the application**

   ```bash
   python src/main.py
   ```

## Building

### Windows Executable

To build the Windows executable:

```bash
cd packaging/windows
build.bat
```

The compiled executable will be available in the `dist/` directory.

## Project Structure

```
yt-music-downloader/
├── src/                    # Python source code
│   └── main.py            # Main application entry point
├── assets/                # Application assets
│   ├── icon.png          # Application icon
│   └── logo.jpeg         # Logo image
├── packaging/             # Build configurations
│   └── windows/          # Windows-specific packaging
│       └── build.bat     # Build script
├── requirements.txt       # Python dependencies
├── YTMusicDownloader.spec # PyInstaller specification
└── README.md             # Project documentation
```

## Technologies Used

- **Python** - Core application logic
- **Tkinter** - GUI framework
- **PyInstaller** - Executable packaging
- **FFmpeg** - Audio processing

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

## Support

If you encounter any issues or have questions, please [open an issue](../../issues) on GitHub.

---

**Educational Use Notice**: This project is created for educational purposes. Please respect copyright laws and YouTube's Terms of Service when using this tool.