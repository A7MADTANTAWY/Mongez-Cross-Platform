# Mongez Deployment Builder for Hostinger
# Run this script to prepare the deployment package.
# Output: deploy/out/  — upload this folder to Hostinger

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$out = Join-Path $PSScriptRoot "out"

Write-Host "=== Building deployment package ===" -ForegroundColor Cyan

# 1. Build frontend
Write-Host "[1/4] Building React frontend..." -ForegroundColor Yellow
Push-Location (Join-Path $root "front")
npm run build
if ($LASTEXITCODE -ne 0) { throw "Frontend build failed" }
Pop-Location

# 2. Clean + create output structure
Write-Host "[2/4] Creating output structure..." -ForegroundColor Yellow
Remove-Item -Recurse -Force $out -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Path (Join-Path $out "public_html") -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $out "backend") -Force | Out-Null

# 3. Copy frontend build to public_html
Write-Host "[3/4] Copying frontend build..." -ForegroundColor Yellow
Copy-Item -Recurse -Path (Join-Path $root "front" "dist", "*") -Destination (Join-Path $out "public_html")
Copy-Item (Join-Path $PSScriptRoot ".htaccess") -Destination (Join-Path $out "public_html" ".htaccess")

# 4. Copy backend files (exclude unnecessary files)
Write-Host "[4/4] Copying backend files..." -ForegroundColor Yellow
$backendOut = Join-Path $out "backend"

# Core Django project files
Copy-Item (Join-Path $root "manage.py") -Destination $backendOut
Copy-Item (Join-Path $root "passenger_wsgi.py") -Destination $backendOut
Copy-Item (Join-Path $root "requirements.txt") -Destination $backendOut
Copy-Item (Join-Path $PSScriptRoot "env.json") -Destination $backendOut

# Copy directories
Copy-Item -Recurse (Join-Path $root "core") -Destination $backendOut
Copy-Item -Recurse (Join-Path $root "apps") -Destination $backendOut

# Create empty data & media dirs (with gitkeep so they aren't gitignored)
New-Item -ItemType Directory -Path (Join-Path $backendOut "data") -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $backendOut "media") -Force | Out-Null

# Collect static files
Write-Host "   Collecting Django static files..." -ForegroundColor Yellow
Push-Location $backendOut
$env:SECRET_KEY = "build-key"
$env:DJANGO_DEBUG = "false"
python manage.py collectstatic --noinput 2>&1 | Out-Null
Pop-Location

# Remove __pycache__ and .pyc
Get-ChildItem -Path $out -Recurse -Directory -Name __pycache__ | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
Get-ChildItem -Path $out -Recurse -Filter "*.pyc" | Remove-Item -Force -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "=== Done! ===" -ForegroundColor Green
Write-Host "Deployment package ready at: $out" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Upload the contents of deploy/out/ to your Hostinger hosting" -ForegroundColor White
Write-Host "2. Set up Python App in hPanel" -ForegroundColor White
Write-Host "3. Run: python manage.py migrate" -ForegroundColor White
Write-Host "4. Run: python manage.py createsuperuser" -ForegroundColor White
