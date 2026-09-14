# Railway — Django REST API
# Built from backend/ as the service root (Root Directory = backend).
# Railway injects $PORT and $DATABASE_URL automatically.

FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PORT=8000

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

# Make entrypoint executable.
RUN chmod +x entrypoint-railway.sh

EXPOSE 8000

ENTRYPOINT ["./entrypoint-railway.sh"]
