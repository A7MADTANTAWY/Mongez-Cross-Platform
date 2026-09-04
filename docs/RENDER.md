# Deploying Mongez on Render

This doc covers deploying the **Django backend** and the **React admin dashboard**
on Render. The Flutter mobile app is built and distributed separately.

## Architecture at a glance

```
React Admin Dashboard        Django REST API         PostgreSQL
(mongez-admin)               (mongez-api)            (mongez-db)
Render Static Site           Render Web Service      Render Database
https://mongez-admin.        https://mongez-api.     Internal URL
  onrender.com                 onrender.com            (DATABASE_URL)
        \                          |                       /
         \--> VITE_API_URL --------+                      /
              (build time)          +-------- DATABASE_URL-+
                                   |
                                   +----> Cloudinary
                                          (media storage)
```

- **Frontend**: `frontend/` — React 19 + Vite, served as a Render Static Site.
- **Backend**: `backend/` — Django + DRF, WSGI via Gunicorn, WhiteNoise serves `/static/`.
- **Database**: PostgreSQL 16, provisioned as a Render Database (free plan).
- **Media**: Cloudinary for uploads (avatars, category images, order attachments).

## Render services

All three are defined in `render.yaml` (Render Blueprint) at the repo root.

| Service | Type | Plan | Root Dir |
|---|---|---|---|
| `mongez-api` | Web (Python) | Free | `backend/` |
| `mongez-admin` | Static Site | Free | `frontend/` |
| `mongez-db` | Database | Free | — |

## Frontend deployment (React dashboard)

| Setting | Value |
|---|---|
| **Root Directory** | `frontend` |
| **Runtime** | `static` |
| **Build Command** | `npm install && npm run build` |
| **Static Publish Path** | `dist` |

### VITE_API_URL (build-time variable)

`VITE_API_URL` is embedded into the JavaScript bundle **at build time** by Vite.
When you change the API URL you must trigger a **manual deploy** (or re-deploy)
from the Render dashboard so the static files are rebuilt with the new value.

Set it in the service environment to your API URL:

```
VITE_API_URL=https://mongez-api.onrender.com
```

### React Router (client-side routing)

The dashboard uses React Router with client-side routing. The static site
service includes a rewrite rule so every path falls back to `index.html`:

```yaml
routes:
  - type: rewrite
    source: /*
    destination: /index.html
```

Without this, hard-refreshing on any page other than `/` (e.g. `/admin/users`)
returns a 404.

## Backend deployment (Django API)

| Setting | Value |
|---|---|
| **Root Directory** | `backend` |
| **Runtime** | Python |
| **Build Command** | `pip install -r requirements.txt && python manage.py collectstatic --noinput` |
| **Start Command** | `gunicorn config.wsgi:application --bind 0.0.0.0:$PORT --workers 2 --timeout 60` |
| **Pre-Deploy (migrate)** | `python manage.py migrate --noinput` |
| **Health check** | `/api/health/` |

Migrations run in the **pre-deploy** step — after the build, before the service
starts. A missing database at *build* time therefore never fails `collectstatic`;
migrate failing means the deploy aborts rather than shipping a broken app.

## Environment variables

Render injects `RENDER=1` and `RENDER_EXTERNAL_HOSTNAME` automatically. The
backend uses them to enable production hardening and to allow its own hostname.

### Required

| Variable | Service | Purpose |
|---|---|---|
| `DJANGO_SECRET_KEY` | `mongez-api` | Signing secret. Startup **fails** if missing in production. Render can auto-generate. |
| `DATABASE_URL` | `mongez-api` | PostgreSQL connection. Render injects it from the linked `mongez-db` database. |
| `CLOUDINARY_CLOUD_NAME` | `mongez-api` | Cloudinary cloud name for media uploads. |
| `CLOUDINARY_API_KEY` | `mongez-api` | Cloudinary API key. |
| `CLOUDINARY_API_SECRET` | `mongez-api` | Cloudinary API secret. |
| `VITE_API_URL` | `mongez-admin` | Backend API URL (embedded at build time). |

### Optional

| Variable | Service | Purpose |
|---|---|---|
| `FRONTEND_URL` | `mongez-api` | Dashboard URL — auto-added to CORS/CSRF allowed origins. |
| `GOOGLE_WEB_CLIENT_ID` | `mongez-api` | Google OAuth Web Client ID. |
| `PAYMOB_API_KEY` | `mongez-api` | Paymob payment gateway key. |
| `PAYMOB_INTEGRATION_ID` | `mongez-api` | Paymob integration ID. |
| `PAYMOB_HMAC_SECRET` | `mongez-api` | Paymob webhook HMAC secret. |
| `FCM_SERVER_KEY` | `mongez-api` | Firebase Cloud Messaging key. |
| `DJANGO_SECURE_HSTS_SECONDS` | `mongez-api` | Set to `31536000` for HSTS. |
| `DJANGO_SECURE_HSTS_INCLUDE_SUBDOMAINS` | `mongez-api` | Set to `true` for HSTS. |

### Cloudinary keys (`sync: false`)

Cloudinary credentials use `sync: false` in `render.yaml` because they contain
secrets. After the **first deploy**, go to the `mongez-api` service in the
Render dashboard → **Environment** tab, and add:

```
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret
```

Cloudinary has a free tier (10 GB storage, 25 GB bandwidth/month) which is
sufficient for a portfolio / staging deployment.

## CORS / CSRF

`settings.py` auto-adds origins in this order:

1. `RENDER_EXTERNAL_HOSTNAME` — the backend's own Render URL.
2. `FRONTEND_URL` — the dashboard Render URL (set in env vars).
3. Any extra origins in `CORS_ALLOWED_ORIGINS` / `CSRF_TRUSTED_ORIGINS`.

After both services are deployed, verify the dashboard URL appears in the
backend CORS origins by visiting `https://<API_URL>/admin/` and checking the
DRF browsable API loads without CORS errors.

## Security hardening (optional, recommended)

| Variable | Value |
|---|---|
| `DJANGO_SECURE_SSL_REDIRECT` | `true` |
| `DJANGO_SECURE_PROXY_SSL_HEADER` | `true` |
| `DJANGO_SESSION_COOKIE_SECURE` | `true` |
| `DJANGO_CSRF_COOKIE_SECURE` | `true` |
| `DJANGO_SECURE_HSTS_SECONDS` | `31536000` |
| `DJANGO_SECURE_HSTS_INCLUDE_SUBDOMAINS` | `true` |

## Media storage

Django currently writes uploads to `cloudinary_storage` in production when
Cloudinary env vars are set, and falls back to the local `backend/media/`
filesystem when they are empty (local development).

Cloudinary replaces the need for a Render Persistent Disk (which requires a
paid plan). Uploads (avatars, category images, order attachments) go directly
to Cloudinary and are served from there.

**Setup steps:**

1. Create a free account at [cloudinary.com](https://cloudinary.com).
2. Copy your **Cloud Name**, **API Key**, and **API Secret** from the dashboard.
3. After first Render deploy, add the three env vars to `mongez-api` (see above).
4. Trigger a manual deploy or restart the service.

## Hostinger / Docker conflict check

Nothing here alters Hostinger/Docker:

- `DATABASES` still falls back to `DB_*` vars when `DATABASE_URL` is unset, so
  the Docker `env_file` and the Hostinger `env.json` still work unchanged.
- `DEFAULT_FILE_STORAGE` falls back to `FileSystemStorage` when
  `CLOUDINARY_CLOUD_NAME` is empty, so local dev and Hostinger keep working.
- Security flags default **off** off-Render, so the Apache/Passenger path is
  unaffected.

## Final deploy steps (in order)

1. Create a Cloudinary free account and copy your credentials.
2. Push the updated code to your repository.
3. In Render dashboard → **New Blueprint**, connect your repo. Render reads
   `render.yaml` and provisions both services and the database.
4. Go to `mongez-api` → **Environment** tab and add:
   - `CLOUDINARY_CLOUD_NAME`, `CLOUDINARY_API_KEY`, `CLOUDINARY_API_SECRET`
   - `GOOGLE_WEB_CLIENT_ID` (if using Google auth)
   - Any Paymob / FCM keys
5. Verify the API: `GET https://<API_URL>/api/health/` returns 200.
6. Verify the dashboard: open `https://<DASHBOARD_URL>/` and log in.
7. For permanent uploads, Cloudinary handles storage — no Render disk needed.

## Updating

When you change `VITE_API_URL` in the dashboard environment, you must trigger a
**manual re-deploy** of the `mongez-admin` service (Render does not auto-rebuild
static sites when env vars change). Click **Manual Deploy** → **Deploy latest
commit** in the Render dashboard.

## Free plan limitations

| Resource | Free tier limit | Impact |
|---|---|---|
| **Backend** | 750 hrs/month | Enough for portfolio staging. Spins down after 15 min inactivity. |
| **Static Site** | 100 GB bandwidth/month | Sufficient for admin dashboard. |
| **PostgreSQL** | 90 days, 1 GB storage | Sufficient for staging. Expires — back up regularly. |
| **Cloudinary** | 10 GB storage, 25 GB bandwidth | Ample for uploads. |
| **Persistent Disk** | Not available on Free | Use Cloudinary instead. |

For a production deployment, upgrade the backend and database to paid plans.
