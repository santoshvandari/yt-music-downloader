@echo off
echo Cleaning previous builds...
rmdir /s /q build
rmdir /s /q dist
del /q main.spec

echo Building executable with PyInstaller...
pyinstaller --onefile --windowed --icon=icon.ico ..\..\src\main.py

echo Build complete.
pause
