from django.core.validators import RegexValidator
from django.db import migrations, models


def delete_all_users(apps, schema_editor):
    """Delete all existing users and their related data before switching to Google auth."""
    User = apps.get_model("users", "User")
    User.objects.all().delete()


phone_validator = RegexValidator(
    regex=r"^\+?[0-9 ()-]{7,20}$",
    message="Enter a valid phone number (digits, optional +, spaces, dashes).",
)


class Migration(migrations.Migration):

    dependencies = [
        ("users", "0005_address"),
    ]

    operations = [
        # Step 1: Delete all existing users (and CASCADE-related data)
        migrations.RunPython(delete_all_users, migrations.RunPython.noop),

        # Step 2: Add Google auth fields
        migrations.AddField(
            model_name="user",
            name="google_id",
            field=models.CharField(
                blank=True,
                db_index=True,
                help_text="Google OAuth sub (unique identifier).",
                max_length=255,
                null=True,
                unique=True,
            ),
        ),
        migrations.AddField(
            model_name="user",
            name="profile_completed",
            field=models.BooleanField(
                db_index=True,
                default=False,
                help_text="Whether the user has completed the required profile fields.",
            ),
        ),

        # Step 3: Make phone nullable for Google users (blank + default "")
        migrations.AlterField(
            model_name="user",
            name="phone",
            field=models.CharField(
                blank=True,
                default="",
                max_length=20,
                unique=True,
                validators=[phone_validator],
            ),
        ),

        # Step 4: Add new indexes
        migrations.AddIndex(
            model_name="user",
            index=models.Index(fields=["google_id"], name="users_google_id_idx"),
        ),
        migrations.AddIndex(
            model_name="user",
            index=models.Index(fields=["profile_completed"], name="users_profile_completed_idx"),
        ),
    ]
