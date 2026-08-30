#!/usr/bin/env bash
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

set -euo pipefail

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"   # deployment/scripts
DEPLOY_DIR="$(dirname "$SCRIPTS_DIR")"                        # deployment
ROOT="$(dirname "$DEPLOY_DIR")"                               # repo root
OUT="$DEPLOY_DIR/out"
FRONTEND_DIR="$ROOT/frontend"
BACKEND_DIR="$ROOT/backend"

say() { printf "%s\n" "==> $*"; }

say "Building React frontend..."
( cd "$FRONTEND_DIR" && npm run build )

say "Creating output structure..."
rm -rf "$OUT"
mkdir -p "$OUT/public_html" "$OUT/backend"

say "Copying frontend build to public_html..."
cp -R "$FRONTEND_DIR"/dist/* "$OUT/public_html/"
cp "$DEPLOY_DIR/hostinger/frontend/.htaccess" "$OUT/public_html/.htaccess"

say "Copying backend files..."
cp "$BACKEND_DIR/manage.py"            "$OUT/backend/"
cp "$BACKEND_DIR/passenger_wsgi.py"    "$OUT/backend/"
cp "$BACKEND_DIR/requirements.txt"     "$OUT/backend/"
cp "$DEPLOY_DIR/hostinger/env.json"    "$OUT/backend/env.json"
cp -R "$BACKEND_DIR/config"            "$OUT/backend/"
cp -R "$BACKEND_DIR/apps"              "$OUT/backend/"

mkdir -p "$OUT/backend/data" "$OUT/backend/media"

say "Collecting Django static files..."
( cd "$OUT/backend" \
  && DJANGO_SECRET_KEY=build-key DJANGO_DEBUG=false python manage.py collectstatic --noinput )

say "Removing Python caches..."
find "$OUT" -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
find "$OUT" -type f -name "*.pyc" -delete 2>/dev/null || true

echo ""
echo "=== Done! ==="
echo "Deployment package ready at: $OUT"
echo ""
echo "Next steps:"
echo "1. Upload the contents of $OUT/ to your Hostinger hosting"
echo "2. Set up Python App in hPanel (root: backend/, entry: passenger_wsgi.py)"
echo "3. Run: python manage.py migrate"
echo "4. Run: python manage.py createsuperuser"
