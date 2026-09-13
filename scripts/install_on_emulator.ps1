# Flutter Local Test & Install Script
# Usage: .\scripts\install_on_emulator.ps1 -Env [prod|dev|local] -SkipPub $true

param (
    [Parameter(Mandatory=$false)]
    [ValidateSet("prod", "dev", "local")]
    [String]$Env = "prod",

    [Parameter(Mandatory=$false)]
    [bool]$SkipPub = $false
)

Write-Host "--- Starting Local Build & Install (Env: $Env) ---" -ForegroundColor Cyan

# 1. Clean build artifacts
Write-Host "Step 1: Cleaning..." -ForegroundColor Yellow
flutter clean

# 2. Get dependencies (Optional)
if (-not $SkipPub) {
    Write-Host "Step 2: Getting dependencies from pub.dev..." -ForegroundColor Yellow
    flutter pub get
} else {
    Write-Host "Step 2: Skipping pub get (offline mode)..." -ForegroundColor Gray
}

# 3. Build Release APK
Write-Host "Step 3: Building Release APK for $Env..." -ForegroundColor Yellow
if ($SkipPub) {
    flutter build apk --release --dart-define=ENVIRONMENT=$Env --android-skip-build-dependency-validation --no-pub
} else {
    flutter build apk --release --dart-define=ENVIRONMENT=$Env --android-skip-build-dependency-validation
}

# 4. Install on the connected emulator
$apkPath = "build/app/outputs/flutter-apk/app-release.apk"

if (Test-Path $apkPath) {
    Write-Host "Step 4: Installing on Emulator..." -ForegroundColor Yellow

    # Sync emulator time (crucial for HTTPS)
    Write-Host "Syncing emulator time..." -ForegroundColor Gray
    adb shell "date `$(date +%m%d%H%M%Y.%S)" 2>$null

    Write-Host "Attempting install via Flutter SDK..." -ForegroundColor Gray
    flutter install

    Write-Host "--- Script Finished ---" -ForegroundColor Green
} else {
    Write-Host "Error: APK file not found at $apkPath" -ForegroundColor Red
}
