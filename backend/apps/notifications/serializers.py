from rest_framework import serializers
from .models import DeviceToken, Notification
from .translations import t


class NotificationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Notification
        fields = ["id", "title", "message", "type", "is_read", "created_at", "data"]
        read_only_fields = fields

    def to_representation(self, instance):
        data = super().to_representation(instance)

        # Lazy translation: rows created with a catalog key are re-translated
        # against the viewer's CURRENT language so old notifications switch
        # language the moment the user changes it in settings. Rows without a
        # key (admin free-text, client-written review) fall back to the stored
        # snapshot untouched.
        if instance.translation_key:
            user = getattr(self.context.get("request"), "user", None)
            if user is not None:
                try:
                    title, message = t(
                        user,
                        instance.translation_key,
                        **dict(instance.translation_params or {}),
                    )
                    data["title"] = title
                    data["message"] = message
                except Exception:
                    pass
        return data


class DeviceTokenSerializer(serializers.ModelSerializer):
    class Meta:
        model = DeviceToken
        fields = ["id", "token", "platform", "is_active", "created_at"]
        read_only_fields = ["id", "is_active", "created_at"]
        extra_kwargs = {
            # Disable the unique validator — the view performs an idempotent
            # update_or_create so re-registering a token must not 400.
            "token": {
                "min_length": 16,
                "max_length": 512,
                "validators": [],
            },
        }
