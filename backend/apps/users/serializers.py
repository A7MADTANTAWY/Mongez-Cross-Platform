from django.contrib.auth import get_user_model
from rest_framework import serializers

from .governorates import GOVERNORATE_CODES
from .models import Address

User = get_user_model()


class UserSerializer(serializers.ModelSerializer):
    """Read-only projection of a user."""

    avatar_url = serializers.SerializerMethodField()
    id_card_url = serializers.SerializerMethodField()
    display_name = serializers.CharField(read_only=True)
    governorate_label = serializers.CharField(source="get_governorate_display", read_only=True)

    average_rating = serializers.SerializerMethodField()
    completed_jobs = serializers.SerializerMethodField()
    worker_id = serializers.SerializerMethodField()

    class Meta:
        model = User
        fields = [
            "id", "username", "name_ar", "display_name",
            "email", "phone", "address",
            "governorate", "governorate_label", "city",
            "role", "avatar_url", "date_joined",
            "profile_completed",
            "average_rating", "completed_jobs", "worker_id",
            "verification_status", "id_card_url",
            "verified_at", "rejection_reason",
        ]
        read_only_fields = fields

    def get_avatar_url(self, obj):
        if not obj.avatar:
            return None
        request = self.context.get("request") if hasattr(self, "context") else None
        url = obj.avatar.url
        return request.build_absolute_uri(url) if request else url

    def get_id_card_url(self, obj):
        if not obj.id_card_image:
            return None
        request = self.context.get("request") if hasattr(self, "context") else None
        url = obj.id_card_image.url
        return request.build_absolute_uri(url) if request else url

    def get_average_rating(self, obj):
        profile = getattr(obj, "worker_profile", None)
        return round(profile.average_rating, 2) if profile else None

    def get_completed_jobs(self, obj):
        profile = getattr(obj, "worker_profile", None)
        return profile.completed_jobs if profile else None

    def get_worker_id(self, obj):
        profile = getattr(obj, "worker_profile", None)
        return profile.id if profile else None


class GoogleSignInSerializer(serializers.Serializer):
    """Accepts a Google id_token and returns/creates the user."""
    id_token = serializers.CharField(max_length=2048)


class AdminLoginSerializer(serializers.Serializer):
    """Username/password login for admin dashboard."""
    username = serializers.CharField()
    password = serializers.CharField(write_only=True)


class CompleteProfileSerializer(serializers.ModelSerializer):
    """Updates profile fields after Google Sign-In (replaces old Register fields)."""
    email = serializers.EmailField(required=False, allow_blank=True)
    name_ar = serializers.CharField(required=False, allow_blank=True, max_length=120)
    address = serializers.CharField(required=False, allow_blank=True, max_length=255)
    city = serializers.CharField(required=False, allow_blank=True, max_length=80)
    governorate = serializers.ChoiceField(
        choices=[(code, code) for code in GOVERNORATE_CODES],
        required=True,
        error_messages={
            "required": "Please pick your governorate.",
            "invalid_choice": "Unknown governorate code. Pick one from /api/governorates/.",
        },
    )
    phone = serializers.CharField(max_length=20, required=True)
    is_default = serializers.BooleanField(default=True)

    class Meta:
        model = User
        fields = [
            "name_ar", "email", "phone", "address",
            "governorate", "city", "role", "avatar",
            "is_default",
        ]
        extra_kwargs = {
            "avatar": {"required": False, "allow_null": True},
        }

    def validate_role(self, value):
        if value == User.Role.ADMIN:
            raise serializers.ValidationError("You cannot register as admin.")
        return value

    def validate_phone(self, value):
        return value

    def update(self, instance, validated_data):
        avatar = validated_data.pop("avatar", None)
        is_default = validated_data.pop("is_default", True)
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        instance.profile_completed = True
        # Workers require admin verification; clients are auto-verified.
        if instance.role == User.Role.WORKER:
            instance.verification_status = User.VerificationStatus.PENDING
        else:
            instance.verification_status = User.VerificationStatus.VERIFIED
        instance.save()
        if avatar is not None:
            instance.avatar = avatar
            instance.save(update_fields=["avatar"])

        # Auto-create a saved Address record so the addresses page isn't empty.
        # Don't duplicate if user already has addresses.
        address_text = validated_data.get("address", "")
        if address_text and not Address.objects.filter(user=instance).exists():
            Address.objects.create(
                user=instance,
                label=validated_data.get("city", ""),
                address=address_text,
                governorate=validated_data.get("governorate", ""),
                city=validated_data.get("city", ""),
                is_default=is_default,
            )

        return instance


class UserUpdateSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = [
            "name_ar", "email", "phone", "address",
            "governorate", "city", "avatar",
        ]
        extra_kwargs = {
            "name_ar": {"required": False, "allow_blank": True},
            "email": {"required": False, "allow_blank": True},
            "phone": {"required": False},
            "address": {"required": False, "allow_blank": True},
            "governorate": {"required": False, "allow_blank": True},
            "city": {"required": False, "allow_blank": True},
            "avatar": {"required": False, "allow_null": True},
        }


class AdminUserCreateSerializer(serializers.ModelSerializer):
    """Used by the admin dashboard to create users manually."""
    password = serializers.CharField(write_only=True, min_length=6)

    class Meta:
        model = User
        fields = [
            "username", "password", "email", "name_ar", "phone",
            "address", "governorate", "city", "role",
        ]

    def validate_role(self, value):
        if value == User.Role.ADMIN:
            raise serializers.ValidationError("Cannot create admin users via this endpoint.")
        return value

    def validate_phone(self, value):
        if value and User.objects.filter(phone=value).exists():
            raise serializers.ValidationError("Phone number is already registered.")
        return value

    def create(self, validated_data):
        password = validated_data.pop("password")
        user = User(**validated_data)
        user.set_password(password)
        user.profile_completed = True
        user.save()
        return user


class AddressSerializer(serializers.ModelSerializer):
    class Meta:
        model = Address
        fields = ["id", "label", "address", "governorate", "city", "is_default"]
        read_only_fields = ["id"]
