import django.db.models.deletion
from django.conf import settings
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ("users", "0007_remove_phone_unique"),
    ]

    operations = [
        migrations.AddField(
            model_name="user",
            name="verification_status",
            field=models.CharField(
                choices=[
                    ("pending", "Pending Verification"),
                    ("verified", "Verified"),
                    ("rejected", "Rejected"),
                ],
                db_index=True,
                default="verified",
                help_text="Only workers need verification; clients are auto-verified.",
                max_length=12,
            ),
        ),
        migrations.AddField(
            model_name="user",
            name="id_card_image",
            field=models.ImageField(
                blank=True,
                help_text="National ID card photo uploaded by the worker during registration.",
                null=True,
                upload_to="id_cards/",
            ),
        ),
        migrations.AddField(
            model_name="user",
            name="verified_at",
            field=models.DateTimeField(
                blank=True,
                help_text="When the admin verified the worker account.",
                null=True,
            ),
        ),
        migrations.AddField(
            model_name="user",
            name="verified_by",
            field=models.ForeignKey(
                blank=True,
                help_text="Admin who verified this worker.",
                null=True,
                on_delete=django.db.models.deletion.SET_NULL,
                related_name="verified_workers",
                to=settings.AUTH_USER_MODEL,
            ),
        ),
        migrations.AddField(
            model_name="user",
            name="rejection_reason",
            field=models.TextField(
                blank=True,
                default="",
                help_text="Reason provided by admin when rejecting a worker.",
            ),
        ),
        migrations.AddIndex(
            model_name="user",
            index=models.Index(
                fields=["verification_status"],
                name="users_verificati_status_idx",
            ),
        ),
    ]
