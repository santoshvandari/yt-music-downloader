@echo off
pyinstaller --onefile --windowed --icon=icon.ico ..\src\main.py
echo Build completed.
pause
