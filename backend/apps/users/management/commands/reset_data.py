"""
management command to reset all data except the admin user.

Usage:
    railway run python manage.py reset_data
"""
import os
import shutil
from django.conf import settings
from django.core.management.base import BaseCommand
from apps.users.models import User


class Command(BaseCommand):
    help = "Delete all users except admin and all related data (orders, ratings, etc.)"

    def add_arguments(self, parser):
        parser.add_argument(
            "--no-media",
            action="store_true",
            help="Skip deleting media files (avatars, attachments, etc.)",
        )

    def handle(self, *args, **options):
        admin_user = User.objects.filter(is_staff=True).first()
        if not admin_user:
            self.stderr.write(self.style.ERROR("No admin user found! Aborting."))
            return

        total_users = User.objects.count()
        users_to_delete = User.objects.exclude(pk=admin_user.pk)
        count = users_to_delete.count()

        self.stdout.write(f"Found {total_users} users. Keeping admin: {admin_user.username}")
        self.stdout.write(f"Deleting {count} users and all related data...")

        # Delete all non-admin users — cascades to:
        #   Addresses, Notifications, DeviceTokens, Favorites, Ratings,
        #   Orders (+ OrderAttachments, CommissionPayments), WorkerProfiles
        users_to_delete.delete()

        # Also delete orphan ServiceCategories (if you want a clean slate)
        from apps.workers.models import ServiceCategory
        cat_count = ServiceCategory.objects.count()
        ServiceCategory.objects.all().delete()
        self.stdout.write(f"Deleted {cat_count} service categories.")

        # Delete media files
        if not options["no_media"]:
            media_root = settings.MEDIA_ROOT
            if os.path.exists(media_root):
                for item in os.listdir(media_root):
                    item_path = os.path.join(media_root, item)
                    if os.path.isdir(item_path):
                        shutil.rmtree(item_path)
                        self.stdout.write(f"  Deleted folder: media/{item}/")
                    else:
                        os.remove(item_path)
                        self.stdout.write(f"  Deleted file: media/{item}")
                self.stdout.write(self.style.SUCCESS("All media files deleted."))
            else:
                self.stdout.write("No media folder found.")

        self.stdout.write(self.style.SUCCESS(
            f"Done! Deleted {count} users, {cat_count} categories, and all related data."
        ))
        self.stdout.write(f"Admin user kept: {admin_user.username} (pk={admin_user.pk})")
