from rest_framework import serializers

from .models import SiteConfig


class SiteConfigSerializer(serializers.ModelSerializer):
    class Meta:
        model = SiteConfig
        fields = [
            "hotline_phone",
            "support_phone",
            "support_email",
            "address",
            "working_hours",
            "response_time_text",
            "facebook_url",
            "twitter_url",
            "instagram_url",
            "linkedin_url",
            "app_store_url",
            "play_store_url",
        ]