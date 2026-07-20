"""Run Django with Waitress (multi-threaded) instead of the single-threaded dev server."""
import os
import sys
from waitress import serve

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
sys.path.append(os.path.join(BASE_DIR, 'core'))

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "core.settings")

import django
django.setup()

from django.core.wsgi import get_wsgi_application
application = get_wsgi_application()

print("Starting Waitress server at http://0.0.0.0:8000/ (multi-threaded)")
serve(application, host="0.0.0.0", port=8000, threads=4)
