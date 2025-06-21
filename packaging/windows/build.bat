@echo off
echo Cleaning old builds...
rmdir /s /q build
rmdir /s /q dist
del /q gui_main.spec

echo Building GUI .exe with PyInstaller...
pyinstaller --onefile --windowed --icon=icon.ico --name=YTMusicDownloader ..\..\src\gui_main.py

echo Done. Your .exe is in dist\
pause
