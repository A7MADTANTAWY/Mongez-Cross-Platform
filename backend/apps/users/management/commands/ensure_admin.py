from django.core.management.base import BaseCommand
from apps.users.models import User


class Command(BaseCommand):
    help = "Create admin superuser if it doesn't exist"

    def handle(self, *args, **options):
        if not User.objects.filter(username="admin").exists():
            user = User.objects.create_superuser(
                "admin", "admin@mongez.com", "admin"
            )
            user.role = "admin"
            user.is_active = True
            user.save()
            self.stdout.write(self.style.SUCCESS("Admin user created."))
        else:
            self.stdout.write("Admin user already exists.")
