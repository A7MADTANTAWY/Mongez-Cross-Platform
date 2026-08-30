# Deploying the Mongez backend on Render

This doc covers deploying the **Django backend only** (`backend/`) on Render as a
Web Service. It does not touch the Hostinger or Docker setup — everything here is
additive so the existing deployments keep working.

## Architecture at a glance

- **Backend**: `backend/` — Django + DRF, WSGI via Gunicorn, WhiteNoise serves `/static/`.
- **Dashboard**: `frontend/` — React build, hosted separately (see Hostinger).
- **Mobile**: `mobile/` — Flutter.
- **Hostinger / Docker**: unchanged (see `deployment/`).

Render hosts only the API. The React dashboard and Flutter app are deployed
elsewhere and configured to point at the Render URL.

## Recommended Render configuration

| Setting | Value |
|---|---|
| **Root Directory** | `backend` |
| **Runtime** | Python |
| **Build Command** | `pip install -r requirements.txt && python manage.py collectstatic --noinput` |
| **Start Command** | `gunicorn config.wsgi:application --bind 0.0.0.0:$PORT --workers 2 --timeout 60` |
| **Pre-Deploy (migrate)** | `python manage.py migrate --noinput` |
| **Health check** | `/api/health/` |

These are also codified in `render.yaml` (Render Blueprint) if you prefer
infrastructure-as-code.

Migrations run in the **pre-deploy** step — after the build, before the service
starts. A missing database at *build* time therefore never fails `collectstatic`;
migrate failing means the deploy aborts rather than shipping a broken app.

## Environment variables required on Render

Render injects `RENDER=1` and `RENDER_EXTERNAL_HOSTNAME` automatically. The
backend uses them to enable production hardening and to allow its own hostname.

| Variable | Required | Purpose |
|---|---|---|
| `DJANGO_SECRET_KEY` | **Yes** | Signing secret. Startup **fails** if missing in production. Generate a long random value (Render can auto-generate). |
| `DJANGO_DEBUG` | No (default `false`) | Set to `false` in production. |
| `DJANGO_ENV` | No (default `production` on Render) | Forces `DEBUG=False` and requires `DJANGO_SECRET_KEY`. |
| `DATABASE_URL` | **Yes** | Render PostgreSQL provides this. Takes priority over all `DB_*` vars. |
| `DJANGO_ALLOWED_HOSTS` | No | Extra comma-separated hosts (the Render hostname is auto-added). |
| `CORS_ALLOWED_ORIGINS` | No | Comma-separated cross-origin allowed (dashboard). Render origin auto-added. |
| `CSRF_TRUSTED_ORIGINS` | No | Comma-separated trusted origins. Render origin auto-added. |
| `DJANGO_TIME_ZONE` | No | default `UTC`. |
| `GOOGLE_WEB_CLIENT_ID` | Yes (if Google auth used) | Web client ID for Sign-In with Google. |
| `PAYMOB_*`, `FCM_SERVER_KEY` | Conditional | Payment / push secrets, same as other hosts. |

Optional security hardening (recommended on Render):

| Variable | Value |
|---|---|
| `DJANGO_SECURE_SSL_REDIRECT` | `true` |
| `DJANGO_SECURE_PROXY_SSL_HEADER` | `true` |
| `DJANGO_SESSION_COOKIE_SECURE` | `true` |
| `DJANGO_CSRF_COOKIE_SECURE` | `true` |
| `DJANGO_SECURE_HSTS_SECONDS` | `31536000` |
| `DJANGO_SECURE_HSTS_INCLUDE_SUBDOMAINS` | `true` |

`SECRET_KEY` must never come from the site files — set it in the Render
dashboard. The local `backend/.env` is gitignored and is for development only.

## Security notes

- `DEBUG` is `False` in production, and the missing-`DJANGO_SECRET_KEY` guard
  prevents shipping a weak key.
- `ALLOWED_HOSTS`, `CORS_ALLOWED_ORIGINS` and `CSRF_TRUSTED_ORIGINS` never use
  `*`. They start from the env list and the Render origin is appended.
- `SECURE_PROXY_SSL_HEADER` is enabled on Render (trusts `X-Forwarded-Proto` from
  Render's proxy). It stays off locally so the dev HTTP server isn't spoofable.
- Secure cookies (`SESSION_COOKIE_SECURE`, `CSRF_COOKIE_SECURE`) default to on
  under Render.

## Media storage (important)

Django currently writes uploads to **`backend/media/` on the local filesystem**
(`MEDIA_URL="media/"`, `MEDIA_ROOT=BASE_DIR/"media"`). On Render the filesystem
is **ephemeral** — files disappear on redeploy and are shared across none of the
instances. So:

- Local development keeps using `media/` (unchanged).
- The existing upload **functionality and API are not modified**.
- For production you should add object storage. The recommended, low-blast-radius
  approach (instead of rewriting the app) is to add a Django storage backend:

  1. Add `django-storages` and the SDK for your provider (e.g. `boto3` for S3 or
     Cloudflare R2), plus the provider URL.
  2. In `config/settings.py`, when `DJANGO_STORAGE_BACKEND in {"s3","r2"}` (or the
     storage env is set), set:
     ```python
     STORAGES = {"default": {"BACKEND": "storages.backends.s3boto3.S3Boto3Storage", "OPTIONS": {...}}}
     ```
  3. Leave `MEDIA_URL` / `MEDIA_ROOT` as the local defaults otherwise, so local
     dev and Hostinger keep working exactly as today.

No models, migrations, serializers or upload views change — only the storage
backend is swapped behind the env flag.

## Hostinger conflict check

Nothing here alters Hostinger/Docker:

- `DATABASES` still falls back to `DB_*` vars when `DATABASE_URL` is unset, so
  the Docker `env_file` and the Hostinger `env.json` still work unchanged.
- Security flags default **off** off-Render, so the Apache/Passenger path is
  unaffected.
- `render.yaml` and `docs/RENDER.md` are new, standalone files — they do not
  override any existing deployment config.

## Final deploy steps (in order)

1. Create a Render **PostgreSQL** instance (e.g. `mongez-db`) → copy its
   `Internal Database URL` (auto-populates `DATABASE_URL`).
2. In the backend Web Service, set:
   - Root Directory = `backend`
   - Build Command = `pip install -r requirements.txt && python manage.py collectstatic --noinput`
   - Start Command = `gunicorn config.wsgi:application --bind 0.0.0.0:$PORT --workers 2 --timeout 60`
   - Pre-Deploy = `python manage.py migrate --noinput`
   - Health Check Path = `/api/health/`
3. Add env vars (see table above): `DJANGO_SECRET_KEY` (random long value),
   `DATABASE_URL`, `CORS_ALLOWED_ORIGINS`, `CSRF_TRUSTED_ORIGINS`, and the
   optional security flags.
4. Deploy. `collectstatic` runs, then `migrate`, then Gunicorn starts.
5. Verify: `GET https://<service>.onrender.com/api/health/` returns 200.
6. Point the React dashboard and Flutter app at the Render API URL
   (`VITE_API_URL` / `API_BASE_URL`).
7. For permanent uploads, follow the object-storage steps under *Media storage*;
   do not rely on the Render disk.
