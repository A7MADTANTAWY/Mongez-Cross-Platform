#!/usr/bin/env python
"""Create the admin superuser if it doesn't exist."""
import os
import django

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "config.settings")
django.setup()

from apps.users.models import User

ADMIN_USERNAME = os.getenv("ADMIN_USERNAME", "admin")
ADMIN_EMAIL = os.getenv("ADMIN_EMAIL", "admin@mongez.com")
ADMIN_PASSWORD = os.getenv("ADMIN_PASSWORD", "MongezAdmin123!")

if not User.objects.filter(username=ADMIN_USERNAME).exists():
    user = User.objects.create_superuser(
        ADMIN_USERNAME, ADMIN_EMAIL, ADMIN_PASSWORD,
    )
    user.role = "admin"
    user.is_active = True
    user.save()
    print(f"Admin user '{ADMIN_USERNAME}' created.")
else:
    print(f"Admin user '{ADMIN_USERNAME}' already exists.")
