# Railway — Django REST API
# Built from backend/ as the service root (Root Directory = backend).
# Railway injects $PORT and $DATABASE_URL automatically.

FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

WORKDIR /app

# Runtime libs for Pillow (JPEG/PNG) and curl (healthcheck)
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        libjpeg62-turbo \
        zlib1g \
        curl \
    && rm -rf /var/lib/apt/lists/*

# Install Python deps first (cached layer).
COPY requirements.txt .
RUN pip install -r requirements.txt

# Copy the backend source.
COPY . .

EXPOSE 8000

# Run migrate + collectstatic + gunicorn at startup (not build time).
# collectstatic is deferred to startup so WhiteNoise doesn't fail on
# missing .map source-map files during the Docker build layer.
CMD python manage.py migrate --noinput \
    && python manage.py collectstatic --noinput \
    && gunicorn config.wsgi:application --bind 0.0.0.0:$PORT --workers 2 --timeout 60
