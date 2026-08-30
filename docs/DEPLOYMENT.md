# Deployment

Mongez is deployed as a monorepo. This document describes the deployment model
after the project restructuring.

## Structure

```
Mongez-Cross-Platform/
├── backend/      → Django REST API + PostgreSQL (external DB)
├── frontend/     → React / Vite (web + admin)
├── mobile/       → Flutter mobile app
├── deployment/   → Docker, Hostinger and scripts (no duplicated source)
└── docs/         → Documentation
```

Deployment configuration is fully separated from application source code
under `deployment/`:

```
deployment/
├── docker/
│   ├── backend/
│   │   └── Dockerfile          # builds from backend/ (repo root context)
│   └── docker-compose.yml      # PostgreSQL + Django web service
├── hostinger/
│   ├── backend/.htaccess       # Django app-root guards (Passenger entry: backend/passenger_wsgi.py)
│   ├── frontend/.htaccess      # SPA rewrite rules
│   └── HOSTINGER_DEPLOY.md     # step-by-step Hostinger guide
└── scripts/
    ├── build.ps1 / build.sh    # build a Hostinger package (deployment/out/)
    ├── deploy.ps1              # build + print upload steps
    ├── start.ps1 / start.sh    # local dev launcher (Docker + Vite + Flutter)
    └── rebuild.sh              # validate all three applications
```

## Docker

Docker configuration lives in `deployment/docker/`. The backend image is built
from the repo root with `backend/` as the single source of truth:

```bash
docker compose -f deployment/docker/docker-compose.yml -p mongez up -d
```

- PostgreSQL runs as the `db` service (an external service to the app).
- The Django web container reads `backend/.env` via `env_file`.
- The dev override (`docker-compose.override.yml`) bind-mounts `backend/`
  source so edits reflect without rebuilding.

## Hostinger

The Hostinger deployment uses Passenger to serve Django from `backend/`
(`passenger_wsgi.py` → `config.wsgi`) and a static React build in
`public_html/`. Generate the package with:

```bash
./deployment/scripts/build.sh        # or build.ps1 on Windows
```

The database is **not** part of the deployed source directories; it stays an
external PostgreSQL service reached via environment variables.

See `deployment/hostinger/HOSTINGER_DEPLOY.md` for the full guide.
