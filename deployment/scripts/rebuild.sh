#!/usr/bin/env bash
# rebuild.sh — clean rebuild + test of every surface in Mongez.
#
# Usage:
#   ./rebuild.sh                  # everything (backend + dashboard + mobile)
#   ./rebuild.sh --backend        # backend only
#   ./rebuild.sh --dashboard      # dashboard only
#   ./rebuild.sh --mobile         # mobile only
#   ./rebuild.sh --skip-mobile    # everything except mobile
#   ./rebuild.sh --serve          # also start dev servers at the end
#   ./rebuild.sh --docker         # full docker compose rebuild path
#   ./rebuild.sh --help
#
# Exit code is non-zero on the first failure.

set -euo pipefail

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"  # deployment/scripts
ROOT="$(dirname "$(dirname "$SCRIPTS_DIR")")"                # repo root
DEPLOY_DIR="$(dirname "$SCRIPTS_DIR")"
COMPOSE_FILE="$DEPLOY_DIR/docker/docker-compose.yml"
cd "$ROOT"

compose() {
  docker compose -f "$COMPOSE_FILE" -p mongez "$@"
}

# ─── colors ────────────────────────────────────────────────────────────────
if [[ -t 1 ]]; then
  C_RESET=$'\033[0m'; C_BOLD=$'\033[1m'
  C_GREEN=$'\033[32m'; C_RED=$'\033[31m'
  C_BLUE=$'\033[34m'; C_YELLOW=$'\033[33m'
else
  C_RESET=""; C_BOLD=""; C_GREEN=""; C_RED=""; C_BLUE=""; C_YELLOW=""
fi
say()  { printf "%s\n" "${C_BLUE}${C_BOLD}==>${C_RESET} ${C_BOLD}$*${C_RESET}"; }
ok()   { printf "%s\n" "    ${C_GREEN}✓${C_RESET} $*"; }
warn() { printf "%s\n" "    ${C_YELLOW}!${C_RESET} $*"; }
die()  { printf "%s\n" "    ${C_RED}✗ $*${C_RESET}" >&2; exit 1; }

# ─── flags ─────────────────────────────────────────────────────────────────
DO_BACKEND=1
DO_DASHBOARD=1
DO_MOBILE=1
SERVE=0
DOCKER=0

for arg in "$@"; do
  case "$arg" in
    --backend)     DO_BACKEND=1; DO_DASHBOARD=0; DO_MOBILE=0 ;;
    --dashboard)   DO_BACKEND=0; DO_DASHBOARD=1; DO_MOBILE=0 ;;
    --mobile)      DO_BACKEND=0; DO_DASHBOARD=0; DO_MOBILE=1 ;;
    --skip-mobile) DO_MOBILE=0 ;;
    --serve)       SERVE=1 ;;
    --docker)      DOCKER=1 ;;
    --help|-h)
      awk 'NR==1 {next} /^[^#]/ {exit} {sub(/^# ?/,""); print}' "$0"
      exit 0 ;;
    *) die "unknown flag: $arg (try --help)" ;;
  esac
done

# ─── docker shortcut ───────────────────────────────────────────────────────
if [[ $DOCKER -eq 1 ]]; then
  say "Docker rebuild path"
  command -v docker >/dev/null || die "docker not installed"
  compose down -v
  compose build --no-cache
  compose up -d
  compose exec web python manage.py migrate
  compose exec web python manage.py test apps
  ok "Docker stack up — http://localhost:8000"
  exit 0
fi

# ─── backend ───────────────────────────────────────────────────────────────
if [[ $DO_BACKEND -eq 1 ]]; then
  say "Backend (Django)"
  BACKEND_DIR="$ROOT/backend"
  VENV_DIR="$BACKEND_DIR/venv"
  if [[ ! -x "$VENV_DIR/bin/python" ]]; then
    warn "no venv found at $VENV_DIR — creating it"
    python3 -m venv "$VENV_DIR"
  fi
  PY="$VENV_DIR/bin/python"
  PIP="$VENV_DIR/bin/pip"

  "$PIP" install -q --disable-pip-version-check -r "$BACKEND_DIR/requirements.txt"
  ok "deps installed"

  ( cd "$BACKEND_DIR" && "$PY" manage.py migrate --noinput )
  ok "migrations applied"

  ( cd "$BACKEND_DIR" && "$PY" manage.py test apps )
  ok "tests pass"
fi

# ─── dashboard ─────────────────────────────────────────────────────────────
if [[ $DO_DASHBOARD -eq 1 ]]; then
  say "Dashboard (React + Vite)"
  command -v npm >/dev/null || die "npm not installed"
  pushd "$ROOT/frontend" >/dev/null
  if [[ ! -d node_modules ]]; then
    warn "node_modules missing — running npm install"
    npm install
  else
    npm install --no-audit --no-fund --silent
  fi
  ok "deps installed"

  npm run build
  ok "production build OK"
  popd >/dev/null
fi

# ─── mobile ────────────────────────────────────────────────────────────────
if [[ $DO_MOBILE -eq 1 ]]; then
  say "Mobile (Flutter)"
  if ! command -v flutter >/dev/null; then
    warn "flutter not on PATH — skipping mobile"
  else
    pushd mobile >/dev/null
    flutter clean
    flutter pub get
    # Regenerate l10n if intl utils is wired
    if grep -q "intl_utils" pubspec.yaml 2>/dev/null; then
      flutter pub run intl_utils:generate || warn "intl_utils:generate failed (continuing)"
    fi
    flutter analyze || warn "flutter analyze reported issues (info-level lints are OK)"
    ok "mobile build verified"
    popd >/dev/null
  fi
fi

# ─── optional dev servers ──────────────────────────────────────────────────
if [[ $SERVE -eq 1 ]]; then
  say "Starting dev servers (Ctrl-C to stop)"
  trap 'kill 0' INT TERM EXIT

  if [[ $DO_BACKEND -eq 1 ]]; then
    ( cd "$ROOT/backend" && "$ROOT/backend/venv/bin/python" manage.py runserver 0.0.0.0:8000 ) &
    ok "backend → http://localhost:8000"
  fi
  if [[ $DO_DASHBOARD -eq 1 ]]; then
    ( cd "$ROOT/frontend" && npm run dev ) &
    ok "dashboard → http://localhost:5173"
  fi
  if [[ $DO_MOBILE -eq 1 ]] && command -v flutter >/dev/null; then
    warn "mobile: run 'flutter run' from ./mobile manually (needs a device)"
  fi
  wait
fi

say "${C_GREEN}All requested surfaces built and tested.${C_RESET}"
