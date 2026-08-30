# Mongez Deployment Builder for Hostinger
#
# Builds a deployment package from the single source of truth:
#   - backend/   -> Django REST API
#   - frontend/  -> React (built via `npm run build`)
#
# Output: deployment/out/  — upload this folder to Hostinger
#
# NOTE: deployment/out/ is generated output. It is NOT committed and is
# excluded from git. Re-run this script whenever you deploy.

$ErrorActionPreference = "Stop"

# repo root = deployment/scripts/../../  ->  two parents up
$scripts = Split-Path -Parent $PSScriptRoot    # deployment
$root    = Split-Path -Parent $scripts         # repo root
$out     = Join-Path $scripts "out"
$frontendDir = Join-Path $root "frontend"
$backendDir  = Join-Path $root "backend"

Write-Host "=== Building deployment package ===" -ForegroundColor Cyan

# 1. Build frontend
Write-Host "[1/4] Building React frontend..." -ForegroundColor Yellow
Push-Location $frontendDir
try {
    npm run build
    if ($LASTEXITCODE -ne 0) { throw "Frontend build failed" }
}
finally {
    Pop-Location
}

# 2. Clean + create output structure
Write-Host "[2/4] Creating output structure..." -ForegroundColor Yellow
Remove-Item -Recurse -Force $out -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Path (Join-Path $out "public_html") -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $out "backend") -Force | Out-Null

# 3. Copy frontend build to public_html
Write-Host "[3/4] Copying frontend build..." -ForegroundColor Yellow
Copy-Item -Recurse -Path (Join-Path $frontendDir "dist", "*") -Destination (Join-Path $out "public_html")
Copy-Item (Join-Path $scripts "hostinger\frontend\.htaccess") -Destination (Join-Path $out "public_html" ".htaccess")

# 4. Copy backend files (exclude unnecessary files)
Write-Host "[4/4] Copying backend files..." -ForegroundColor Yellow
$backendOut = Join-Path $out "backend"

# Django project files
Copy-Item (Join-Path $backendDir "manage.py") -Destination $backendOut
Copy-Item (Join-Path $backendDir "passenger_wsgi.py") -Destination $backendOut
Copy-Item (Join-Path $backendDir "requirements.txt") -Destination $backendOut
Copy-Item (Join-Path $scripts "hostinger\env.json") -Destination (Join-Path $backendOut "env.json")

# Source directories (config + apps only; media/uploads are kept separate)
Copy-Item -Recurse (Join-Path $backendDir "config") -Destination $backendOut
Copy-Item -Recurse (Join-Path $backendDir "apps") -Destination $backendOut

# Create empty data & media dirs on the host
New-Item -ItemType Directory -Path (Join-Path $backendOut "data") -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $backendOut "media") -Force | Out-Null

# Collect static files
Write-Host "   Collecting Django static files..." -ForegroundColor Yellow
Push-Location $backendOut
try {
    $env:DJANGO_SECRET_KEY = "build-key"
    $env:DJANGO_DEBUG = "false"
    python manage.py collectstatic --noinput 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "collectstatic failed" }
}
finally {
    Pop-Location
}

# Remove __pycache__ and .pyc
Get-ChildItem -Path $out -Recurse -Directory -Name __pycache__ | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
Get-ChildItem -Path $out -Recurse -Filter "*.pyc" | Remove-Item -Force -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "=== Done! ===" -ForegroundColor Green
Write-Host "Deployment package ready at: $out" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Upload the contents of deployment/out/ to your Hostinger hosting" -ForegroundColor White
Write-Host "2. Set up Python App in hPanel (root: backend/, entry: passenger_wsgi.py)" -ForegroundColor White
Write-Host "3. Run: python manage.py migrate" -ForegroundColor White
Write-Host "4. Run: python manage.py createsuperuser" -ForegroundColor White
