; ─── THE ASHEN ROAD — INNO SETUP INSTALLER SCRIPT ───────────────────────────
;
; HOW TO USE:
;   1. Install Inno Setup from https://jrsoftware.org/isinfo.php (free)
;   2. Run scripts\build_release.ps1 — it builds the game AND compiles this script.
;   OR open this file in Inno Setup and click Build > Compile.
;
; The installer bundles everything from the Release build folder into a
; single .exe that playtesters double-click to install the game.

#define AppName      "The Ashen Road"
#define AppVersion   "1.0.0"
#define AppPublisher "Project Alpha"
#define AppExeName   "the_ashen_road.exe"
#define BuildDir     "..\build\windows\x64\runner\Release"
#define OutputDir    "..\installer\output"

[Setup]
AppId={{A3F2C1D0-8B4E-4A9F-B7C6-2E1D5F3A8B90}
AppName={#AppName}
AppVersion={#AppVersion}
AppPublisher={#AppPublisher}
AppPublisherURL=https://github.com/davon768/the-ashen-road
AppSupportURL=https://github.com/davon768/the-ashen-road/issues
DefaultDirName={autopf}\{#AppName}
DefaultGroupName={#AppName}
; Show a license file if you have one — comment this out if not
; LicensFile=..\LICENSE.txt
OutputDir={#OutputDir}
OutputBaseFilename=AshenRoadInstaller_v{#AppVersion}
SetupIconFile={#BuildDir}\data\flutter_assets\assets\icon\icon.ico
; Fall back to no icon if the above path doesn't exist — remove the line instead
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern
; Require Windows 10 or later
MinVersion=10.0
ArchitecturesInstallIn64BitMode=x64
DisableDirPage=no
DisableProgramGroupPage=yes

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "Create a &desktop shortcut"; GroupDescription: "Additional icons:"

[Files]
; Copy the entire release build — exe, all DLLs, and the data folder.
Source: "{#BuildDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
; Start Menu shortcut
Name: "{group}\{#AppName}"; Filename: "{app}\{#AppExeName}"
; Desktop shortcut (only if user chose the task above)
Name: "{commondesktop}\{#AppName}"; Filename: "{app}\{#AppExeName}"; Tasks: desktopicon

[Run]
; Offer to launch the game after installation
Filename: "{app}\{#AppExeName}"; \
  Description: "Launch {#AppName}"; \
  Flags: nowait postinstall skipifsilent

[UninstallDelete]
; Remove the save data folder when uninstalling (optional — comment out to keep saves)
; Type: filesandordirs; Name: "{localappdata}\AshenRoad"

[Code]
// Show a message if Visual C++ Redistributable might be needed.
// Flutter bundles what it needs, so this is usually fine without an extra step.
procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then
  begin
    // Nothing extra needed — Flutter is fully self-contained.
  end;
end;
