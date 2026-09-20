from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase, APIRequestFactory

from apps.users.models import User
from .models import DeviceToken, Notification
from .serializers import NotificationSerializer
from .services import notify


class NotificationTests(APITestCase):
    def setUp(self):
        self.user = User.objects.create_user(
            username="bob", phone="+201000000040", password="Sup3r-Secret!",
            role=User.Role.CLIENT, profile_completed=True,
        )
        self.client.force_authenticate(user=self.user)

    def test_notify_persists_row(self):
        notif = notify(user=self.user, title="Hi", message="There")
        self.assertEqual(Notification.objects.count(), 1)
        self.assertEqual(notif.title, "Hi")

    def test_unread_count_endpoint(self):
        notify(user=self.user, title="A", message="B")
        notify(user=self.user, title="C", message="D")
        response = self.client.get(reverse("notification-unread-count"))
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data["unread"], 2)

    def test_mark_all_read(self):
        notify(user=self.user, title="A", message="B")
        notify(user=self.user, title="C", message="D")
        response = self.client.post(reverse("notification-read-all"))
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(
            Notification.objects.filter(user=self.user, is_read=False).count(), 0,
        )

    def test_register_device_token_idempotent(self):
        url = reverse("notification-device-register")
        first = self.client.post(url, {"token": "abcd1234abcd1234", "platform": "android"}, format="json")
        self.assertEqual(first.status_code, status.HTTP_201_CREATED)
        second = self.client.post(url, {"token": "abcd1234abcd1234", "platform": "android"}, format="json")
        self.assertEqual(second.status_code, status.HTTP_201_CREATED)
        self.assertEqual(DeviceToken.objects.count(), 1)

    def test_notify_with_translation_key_stores_key_params_and_snapshot(self):
        notif = notify(
            user=self.user,
            notif_type=Notification.PUSH,
            translation_key="order_rejected",
            translation_params={"order_id": 7},
        )
        self.assertEqual(Notification.objects.count(), 1)
        self.assertEqual(notif.translation_key, "order_rejected")
        self.assertEqual(notif.translation_params, {"order_id": 7})
        # Default language is English → stored snapshot is the EN text.
        self.assertEqual(notif.title, "Order Rejected ❌")
        self.assertIn("#7", notif.message)

    def test_notify_without_key_is_backwards_compatible(self):
        notif = notify(user=self.user, title="Hi", message="There")
        self.assertEqual(notif.title, "Hi")
        self.assertEqual(notif.message, "There")
        self.assertEqual(notif.translation_key, "")
        self.assertEqual(notif.translation_params, {})

    def test_serializer_retranslates_lazily_on_language_change(self):
        notif = notify(
            user=self.user,
            notif_type=Notification.IN_APP,
            translation_key="order_accepted",
            translation_params={"username": "Ahmed", "order_id": 9},
        )
        factory = APIRequestFactory()
        self.user.language = "en"
        request_en = factory.get(reverse("notification-list"))
        request_en.user = self.user
        data_en = NotificationSerializer(
            notif, context={"request": request_en},
        ).data
        self.assertEqual(data_en["title"], "Order Accepted ✅")

        # Changing the user's language re-translates the same old row.
        self.user.language = "ar"
        request_ar = factory.get(reverse("notification-list"))
        request_ar.user = self.user
        data_ar = NotificationSerializer(
            notif, context={"request": request_ar},
        ).data
        self.assertEqual(data_ar["title"], "تم قبول الطلب ✅")
