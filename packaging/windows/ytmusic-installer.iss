; Inno Setup Script for YT Music Downloader
; Save this file as packaging/windows/ytmusic-installer.iss

[Setup]
AppName=YT Music Downloader
AppVersion=1.0
DefaultDirName={pf}\YT Music Downloader
DefaultGroupName=YT Music Downloader
OutputBaseFilename=YTMusicDownloader_Installer
Compression=lzma
SolidCompression=yes
WizardStyle=modern
DisableDirPage=no
UninstallDisplayIcon={app}\YTMusicDownloader.exe
SetupIconFile=icon.ico

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Files]
Source: ".\dist\YTMusicDownloader.exe"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{group}\YT Music Downloader"; Filename: "{app}\YTMusicDownloader.exe"
Name: "{commondesktop}\YT Music Downloader"; Filename: "{app}\YTMusicDownloader.exe"; Tasks: desktopicon

[Tasks]
Name: "desktopicon"; Description: "Create a &desktop icon"; GroupDescription: "Additional icons:"; Flags: unchecked

[Run]
Filename: "{app}\YTMusicDownloader.exe"; Description: "Launch YT Music Downloader"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
Type: files; Name: "{app}\YTMusicDownloader.exe"
