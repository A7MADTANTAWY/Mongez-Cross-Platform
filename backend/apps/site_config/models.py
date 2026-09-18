from django.db import models


class SiteConfig(models.Model):
    """Singleton site-wide configuration editable from the admin panel.

    Rather than hardcoding (and risking faking) contact details on the
    landing page / footer, the values live here and the owner sets the
    real ones from the dashboard Settings page. The public `/api/home/`
    endpoint serves them read-only.
    """

    class Meta:
        verbose_name = "Site configuration"
        verbose_name_plural = "Site configuration"

    # Contact
    hotline_phone = models.CharField(
        max_length=30, blank=True, default="",
        help_text="Emergency hotline shown on the landing page.",
    )
    support_phone = models.CharField(
        max_length=30, blank=True, default="",
        help_text="Support phone shown in the footer.",
    )
    support_email = models.EmailField(blank=True, default="")
    address = models.CharField(max_length=255, blank=True, default="")
    working_hours = models.CharField(max_length=120, blank=True, default="")
    response_time_text = models.CharField(
        max_length=120, blank=True, default="",
        help_text="Landing page 'average response time' wording (admin-editable text).",
    )

    # Social links (empty = hidden from the footer)
    facebook_url = models.URLField(blank=True, default="")
    twitter_url = models.URLField(blank=True, default="")
    instagram_url = models.URLField(blank=True, default="")
    linkedin_url = models.URLField(blank=True, default="")

    # App store download links (empty = hidden)
    app_store_url = models.URLField(
        blank=True, default="",
        help_text="iOS / App Store download link.",
    )
    play_store_url = models.URLField(
        blank=True, default="",
        help_text="Android / Google Play download link.",
    )

    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return "Site configuration"

    @classmethod
    def singleton(cls):
        """Return the single SiteConfig row, creating a blank one on first use."""
        obj, _created = cls.objects.get_or_create(pk=1)
        return obj