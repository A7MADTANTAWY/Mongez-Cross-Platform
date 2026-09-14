#!/bin/bash
set -e

echo "=== Mongez Backend Starting ==="
echo "PORT=${PORT:-8000}"
echo "DATABASE_URL set: $([ -n \"$DATABASE_URL\" ] && echo 'yes' || echo 'no')"

echo "Applying database migrations..."
python manage.py migrate --noinput

echo "Collecting static files..."
python manage.py collectstatic --noinput

# Railway injects PORT. If unset, default to 8000.
PORT="${PORT:-8000}"

echo "Starting Gunicorn on 0.0.0.0:${PORT}..."
exec gunicorn config.wsgi:application \
    --bind "0.0.0.0:${PORT}" \
    --workers 2 \
    --timeout 60 \
    --access-logfile - \
    --error-logfile -
