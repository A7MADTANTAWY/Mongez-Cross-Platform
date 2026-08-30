# Mongez Deploy script for Hostinger
#
# Builds the deployment package (via build.ps1) and prints the upload steps.
#
# Usage:
#   ./deploy.ps1            # build the package and show upload instructions
#   ./deploy.ps1 -SkipBuild # skip rebuild, package must already exist
#
# The actual upload is done through Hostinger hPanel (File Manager / FTP).

param(
    [switch]$SkipBuild
)

$ErrorActionPreference = "Stop"

$scripts = Split-Path -Parent $PSScriptRoot     # deployment
$root    = Split-Path -Parent $scripts         # repo root
$out     = Join-Path $scripts "out"

if (-not $SkipBuild) {
    & (Join-Path $PSScriptRoot "build.ps1")
    if ($LASTEXITCODE -ne 0) { throw "build.ps1 failed" }
}

if (-not (Test-Path (Join-Path $out "backend"))) {
    throw "No deployment package found at $out. Run .\deploy.ps1 (without -SkipBuild) first."
}

Write-Host ""
Write-Host "=== Upload to Hostinger ===" -ForegroundColor Cyan
Write-Host "1. Open hPanel -> File Manager (https://hpanel.hostinger.com/)" -ForegroundColor White
Write-Host "2. Upload folder: $out\backend  ->  into your domain's app root"     -ForegroundColor White
Write-Host "3. Upload contents of: $out\public_html  ->  into public_html/"      -ForegroundColor White
Write-Host "4. Setup Python App: root = backend/, entry point = passenger_wsgi.py" -ForegroundColor White
Write-Host "5. Edit backend/env.json with real DB + secrets"                     -ForegroundColor White
Write-Host "6. Run (hPanel -> Run Python Script): python manage.py migrate"      -ForegroundColor White
Write-Host "7. Run: python manage.py createsuperuser"                            -ForegroundColor White
Write-Host ""
Write-Host "See deployment/hostinger/HOSTINGER_DEPLOY.md for full details." -ForegroundColor DarkGray
