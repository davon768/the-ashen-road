# ─── THE ASHEN ROAD — RELEASE BUILD SCRIPT ────────────────────────────────────
#
# Run this script from PowerShell to:
#   1. Build the release Windows executable
#   2. Compile the Inno Setup installer
#   3. Output AshenRoadInstaller_vX.Y.Z.exe in installer\output\
#
# Prerequisites (one-time setup):
#   - Flutter SDK installed and on your PATH
#   - Inno Setup 6 installed: https://jrsoftware.org/isinfo.php
#     Default install path: C:\Program Files (x86)\Inno Setup 6\ISCC.exe
#
# Usage:
#   cd "C:\Users\Owner\Documents\Project Alpha\the_ashen_road"
#   .\scripts\build_release.ps1
#
# To release a new version:
#   1. Update version in pubspec.yaml  (e.g. 1.0.1+2)
#   2. Update kAppVersion in lib\config\app_version.dart  (e.g. 1.0.1)
#   3. Update AppVersion in installer\AshenRoad.iss  (e.g. 1.0.1)
#   4. Run this script
#   5. Upload installer\output\AshenRoadInstaller_vX.Y.Z.exe to GitHub Releases
# ──────────────────────────────────────────────────────────────────────────────

$ErrorActionPreference = 'Stop'

$ProjectRoot = Split-Path -Parent $PSScriptRoot
$InnoSetupPath = "C:\Program Files\Inno Setup 7\ISCC.exe"
$IssFile = Join-Path $ProjectRoot "installer\AshenRoad.iss"
$OutputDir = Join-Path $ProjectRoot "installer\output"

Write-Host ""
Write-Host "============================================" -ForegroundColor DarkYellow
Write-Host "  THE ASHEN ROAD — RELEASE BUILD" -ForegroundColor Yellow
Write-Host "============================================" -ForegroundColor DarkYellow
Write-Host ""

# ── Step 1: Flutter release build ──────────────────────────────────────────────
Write-Host "[1/3] Building Flutter Windows release..." -ForegroundColor Cyan
Set-Location $ProjectRoot
flutter build windows --release
if ($LASTEXITCODE -ne 0) { throw "Flutter build failed." }
Write-Host "      Build complete." -ForegroundColor Green

# ── Step 2: Create output directory ────────────────────────────────────────────
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir | Out-Null
}

# ── Step 3: Compile Inno Setup installer ───────────────────────────────────────
if (Test-Path $InnoSetupPath) {
    Write-Host "[2/3] Compiling installer with Inno Setup..." -ForegroundColor Cyan
    & $InnoSetupPath $IssFile
    if ($LASTEXITCODE -ne 0) { throw "Inno Setup compilation failed." }
    Write-Host "      Installer compiled." -ForegroundColor Green
} else {
    Write-Host "[2/3] Inno Setup not found at: $InnoSetupPath" -ForegroundColor Yellow
    Write-Host "      Download from https://jrsoftware.org/isinfo.php and install," -ForegroundColor Yellow
    Write-Host "      then re-run this script to generate the installer." -ForegroundColor Yellow
    Write-Host "      (The release build itself is still at build\windows\x64\runner\Release\)" -ForegroundColor Gray
}

# ── Step 4: Open output folder ─────────────────────────────────────────────────
Write-Host "[3/3] Done!" -ForegroundColor Green
Write-Host ""

if (Test-Path $OutputDir) {
    $installers = Get-ChildItem -Path $OutputDir -Filter "*.exe" | Sort-Object LastWriteTime -Descending
    if ($installers.Count -gt 0) {
        $latest = $installers[0]
        Write-Host "  Installer: $($latest.Name)" -ForegroundColor Yellow
        Write-Host "  Size:      $([math]::Round($latest.Length / 1MB, 1)) MB" -ForegroundColor Gray
        Write-Host "  Path:      $($latest.FullName)" -ForegroundColor Gray
        Write-Host ""
        Write-Host "  Next step: Upload this file to a new GitHub Release." -ForegroundColor Cyan
        Write-Host "  Playtesters download and run it to install the latest build." -ForegroundColor Cyan
        # Open the output folder in Explorer
        Invoke-Item $OutputDir
    }
}

Write-Host ""
