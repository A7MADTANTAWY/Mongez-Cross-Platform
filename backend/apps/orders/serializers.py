from rest_framework import serializers
from apps.users.models import User, Address
from apps.users.serializers import UserSerializer, AddressSerializer
from apps.workers.models import ServiceCategory, WorkerProfile
from apps.workers.serializers import ServiceCategorySerializer
from .models import Order, OrderAttachment


class OrderAttachmentSerializer(serializers.ModelSerializer):
    file_url = serializers.SerializerMethodField()

    class Meta:
        model = OrderAttachment
        fields = [
            "id", "kind", "file", "file_url", "caption",
            "duration_seconds", "size_bytes", "created_at",
        ]
        read_only_fields = ["id", "size_bytes", "created_at", "file_url"]
        extra_kwargs = {"file": {"write_only": True}}

    def get_file_url(self, obj):
        if not obj.file:
            return None
        request = self.context.get("request") if hasattr(self, "context") else None
        url = obj.file.url
        return request.build_absolute_uri(url) if request else url


class OrderSerializer(serializers.ModelSerializer):

    client = UserSerializer(read_only=True)
    worker = UserSerializer(read_only=True)
    service_category = ServiceCategorySerializer(read_only=True)
    commission_payment = serializers.SerializerMethodField()
    attachments = OrderAttachmentSerializer(many=True, read_only=True)
    is_rated = serializers.SerializerMethodField()
    address = AddressSerializer(read_only=True)

    class Meta:
        model = Order
        fields = [
            "id",
            "client",
            "worker",
            "service_category",
            "description",
            "address",
            "address_text",
            "latitude",
            "longitude",
            "urgency",
            "scheduled_for",
            "commission",
            "status",
            "attachments",
            "created_at",
            "accepted_at",
            "completed_at",
            "cancelled_at",
            "commission_payment",
            "is_rated",
        ]

    def get_commission_payment(self, order):
        try:
            p = order.commission_payment
            return {
                "amount": str(p.amount),
                "payment_status": p.payment_status,
                "paymob_order_id": p.paymob_order_id,
                "paymob_transaction_id": p.paymob_transaction_id,
            }
        except Exception:
            return None

    def get_is_rated(self, order):
        return hasattr(order, 'rating')


class OrderCreateSerializer(serializers.ModelSerializer):

    service_category = serializers.PrimaryKeyRelatedField(
        queryset=ServiceCategory.objects.all(),
    )
    worker_id = serializers.PrimaryKeyRelatedField(
        queryset   = User.objects.filter(role=User.Role.WORKER),
        source = "worker",
        required = False,
        allow_null = True,
    )
    address_id = serializers.PrimaryKeyRelatedField(
        queryset = Address.objects.all(),
        source = "address",
        required = False,
        allow_null = True,
    )

    class Meta:
        model  = Order
        fields = [
            "service_category", "worker_id",
            "description", "address_text", "address_id",
            "latitude", "longitude",
            "urgency", "scheduled_for",
        ]

    def validate(self, attrs):
        """Validate worker against category when worker_id is provided."""
        worker = attrs.get("worker")
        service_category = attrs.get("service_category")
        address = attrs.get("address")

        if address is not None:
            request = self.context.get("request")
            if request and address.user != request.user:
                raise serializers.ValidationError(
                    {"address_id": "This address does not belong to you."}
                )
        else:
            # Every order must have an address.
            raise serializers.ValidationError(
                {"address_id": "Please select an address for this order."}
            )

        if worker is None:
            return attrs

        if not hasattr(worker, "worker_profile"):
            raise serializers.ValidationError(
                {"worker_id": "This worker does not have a profile yet."}
            )

        profile = worker.worker_profile

        if not profile.is_available:
            raise serializers.ValidationError(
                {"worker_id": "This worker is not currently available."}
            )

        if profile.profession.lower() != service_category.name.lower():
            raise serializers.ValidationError(
                {
                    "worker_id": (
                        f"Worker's profession '{profile.profession}' does not match "
                        f"the selected category '{service_category.name}'."
                    )
                }
            )

        return attrs
