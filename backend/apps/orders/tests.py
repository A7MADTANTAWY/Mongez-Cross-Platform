from datetime import timedelta
from unittest.mock import patch

from django.core.files.uploadedfile import SimpleUploadedFile
from django.urls import reverse
from django.utils import timezone
from rest_framework import status
from rest_framework.test import APITestCase

from apps.notifications.models import Notification
from apps.users.models import Address, User
from apps.workers.models import ServiceCategory, WorkerProfile
from .models import Order, OrderAttachment


class OrderLifecycleTests(APITestCase):
    @classmethod
    def setUpTestData(cls):
        cls.category = ServiceCategory.objects.create(name="Plumbing")
        cls.client_user = User.objects.create_user(
            username="cliff", phone="+201000000010", password="Sup3r-Secret!",
            role=User.Role.CLIENT, profile_completed=True,
        )
        cls.worker_user = User.objects.create_user(
            username="will", phone="+201000000011", password="Sup3r-Secret!",
            role=User.Role.WORKER, profile_completed=True,
        )
        WorkerProfile.objects.create(
            user=cls.worker_user, profession="Plumbing", experience_years=3,
        )
        cls.address = Address.objects.create(
            user=cls.client_user, label="Home",
            address="12 Test St", governorate="cairo", city="Nasr City",
            is_default=True,
        )

    def _create_order(self):
        with patch("apps.orders.views.authorize_commission", return_value="dummy_key"):
            self.client.force_authenticate(user=self.client_user)
            return self.client.post(reverse("order-list-create"), {
                "service_category": self.category.id,
                "worker_id": self.worker_user.id,
                "address_id": self.address.id,
            }, format="json")

    def test_client_can_create_pending_order(self):
        response = self._create_order()
        self.assertEqual(response.status_code, status.HTTP_201_CREATED, response.data)
        self.assertEqual(response.data["status"], Order.PENDING)

    def test_worker_can_accept_order(self):
        create_resp = self._create_order()
        order_id = create_resp.data["id"]

        self.client.force_authenticate(user=self.worker_user)
        with patch("apps.orders.views.paymob.capture_commission", return_value={}):
            accept_resp = self.client.post(reverse("order-accept", args=[order_id]))
        self.assertEqual(accept_resp.status_code, status.HTTP_200_OK, accept_resp.data)
        self.assertEqual(accept_resp.data["status"], Order.ACCEPTED)

    def test_two_step_completion_requires_client_confirmation(self):
        create_resp = self._create_order()
        order_id = create_resp.data["id"]

        # Worker accepts then marks finished — should land in WAITING_CONFIRMATION,
        # NOT bump completed_jobs yet.
        self.client.force_authenticate(user=self.worker_user)
        with patch("apps.orders.views.paymob.capture_commission", return_value={}):
            self.client.post(reverse("order-accept", args=[order_id]))
        mark_resp = self.client.post(reverse("order-complete", args=[order_id]))
        self.assertEqual(mark_resp.status_code, status.HTTP_200_OK, mark_resp.data)
        self.assertEqual(mark_resp.data["status"], Order.WAITING_CONFIRMATION)
        self.worker_user.worker_profile.refresh_from_db()
        self.assertEqual(self.worker_user.worker_profile.completed_jobs, 0)

        # Client confirms — order closes, counter bumps.
        self.client.force_authenticate(user=self.client_user)
        confirm_resp = self.client.post(reverse("order-confirm-completion", args=[order_id]))
        self.assertEqual(confirm_resp.status_code, status.HTTP_200_OK, confirm_resp.data)
        self.assertEqual(confirm_resp.data["status"], Order.COMPLETED)
        self.worker_user.worker_profile.refresh_from_db()
        self.assertEqual(self.worker_user.worker_profile.completed_jobs, 1)

    def test_worker_cannot_order_in_own_profession(self):
        self.client.force_authenticate(user=self.worker_user)
        with patch("apps.orders.views.authorize_commission", return_value="dummy_key"):
            resp = self.client.post(reverse("order-list-create"), {
                "service_category": self.category.id,
                "address_id": self.address.id,
            }, format="json")
        self.assertEqual(resp.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn("service_category", resp.data)

    def test_worker_can_order_other_category(self):
        other = ServiceCategory.objects.create(name="Electrical")
        electrician = User.objects.create_user(
            username="ed", phone="+201000000012", password="Sup3r-Secret!",
            role=User.Role.WORKER, profile_completed=True,
        )
        WorkerProfile.objects.create(
            user=electrician, profession="Electrical", experience_years=2,
        )
        self.client.force_authenticate(user=self.worker_user)
        with patch("apps.orders.views.authorize_commission", return_value="dummy_key"):
            resp = self.client.post(reverse("order-list-create"), {
                "service_category": other.id,
                "worker_id": electrician.id,
                "address_id": self.address.id,
            }, format="json")
        self.assertEqual(resp.status_code, status.HTTP_201_CREATED, resp.data)
        self.assertEqual(resp.data["status"], Order.PENDING)

    def test_client_cannot_accept_order(self):
        create_resp = self._create_order()
        order_id = create_resp.data["id"]

        self.client.force_authenticate(user=self.client_user)
        accept_resp = self.client.post(reverse("order-accept", args=[order_id]))
        self.assertEqual(accept_resp.status_code, status.HTTP_403_FORBIDDEN)

    def test_cannot_accept_already_accepted_order(self):
        create_resp = self._create_order()
        order_id = create_resp.data["id"]

        self.client.force_authenticate(user=self.worker_user)
        with patch("apps.orders.views.paymob.capture_commission", return_value={}):
            self.client.post(reverse("order-accept", args=[order_id]))
            second = self.client.post(reverse("order-accept", args=[order_id]))
        self.assertEqual(second.status_code, status.HTTP_400_BAD_REQUEST)

    def test_client_can_cancel_pending_order(self):
        create_resp = self._create_order()
        order_id = create_resp.data["id"]

        with patch("apps.orders.views.paymob.void_commission", return_value={}):
            cancel_resp = self.client.post(reverse("order-cancel", args=[order_id]))
        self.assertEqual(cancel_resp.status_code, status.HTTP_200_OK, cancel_resp.data)
        self.assertEqual(cancel_resp.data["status"], Order.CANCELLED)

    def test_filter_orders_by_status(self):
        self._create_order()
        self.client.force_authenticate(user=self.client_user)
        response = self.client.get(reverse("order-list-create"), {"status": "PENDING"})
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        statuses = {o["status"] for o in response.data}
        self.assertEqual(statuses, {Order.PENDING})


class OrderCancellationReasonTests(APITestCase):
    """The cancellation flow must record *why* an order was cancelled so the
    admin can tell a worker-delay cancellation apart from any other reason —
    without ever assuming a reason the client didn't state."""

    @classmethod
    def setUpTestData(cls):
        cls.category = ServiceCategory.objects.create(name="Plumbing")
        cls.client_user = User.objects.create_user(
            username="delay_client", phone="+201000000020", password="Sup3r-Secret!",
            role=User.Role.CLIENT, profile_completed=True,
        )
        cls.worker_user = User.objects.create_user(
            username="slow_worker", phone="+201000000021", password="Sup3r-Secret!",
            role=User.Role.WORKER, profile_completed=True,
        )
        WorkerProfile.objects.create(
            user=cls.worker_user, profession="Plumbing", experience_years=3,
        )
        cls.admin_user = User.objects.create_user(
            username="admin_delay", phone="+201000000022", password="Sup3r-Secret!",
            role=User.Role.ADMIN, profile_completed=True,
        )
        cls.address = Address.objects.create(
            user=cls.client_user, label="Home",
            address="12 Test St", governorate="cairo", city="Nasr City",
        )

    def _accepted_order(self):
        return Order.objects.create(
            client=self.client_user,
            worker=self.worker_user,
            service_category=self.category,
            address=self.address,
            status=Order.ACCEPTED,
            # A worker was accepted 2h ago and never showed up.
            accepted_at=timezone.now() - timedelta(hours=2),
            created_at=timezone.now() - timedelta(hours=3),
        )

    def test_cancel_with_worker_delay_reason_is_recorded_and_notifies_admins(self):
        order = self._accepted_order()

        self.client.force_authenticate(user=self.client_user)
        with patch("apps.orders.views.paymob.void_commission", return_value={}):
            resp = self.client.post(
                reverse("order-cancel", args=[order.id]),
                {"reason": Order.WORKER_DELAY}, format="json",
            )

        self.assertEqual(resp.status_code, status.HTTP_200_OK, resp.data)
        self.assertEqual(resp.data["status"], Order.CANCELLED)
        self.assertEqual(resp.data["cancellation_reason"], Order.WORKER_DELAY)

        order.refresh_from_db()
        self.assertEqual(order.cancellation_reason, Order.WORKER_DELAY)
        self.assertIsNotNone(order.cancelled_at)

        # The admin received a notification naming the order and the worker.
        notifs = self.admin_user.notifications.all()
        self.assertTrue(notifs.exists())
        latest = notifs.first()
        self.assertIn(str(order.id), latest.message)
        self.assertIn("slow_worker", latest.message)
        self.assertEqual(latest.data.get("order_id"), order.id)
        self.assertEqual(latest.data.get("reason"), Order.WORKER_DELAY)

    def test_cancel_without_reason_leaves_reason_blank(self):
        order = self._accepted_order()

        self.client.force_authenticate(user=self.client_user)
        with patch("apps.orders.views.paymob.void_commission", return_value={}):
            resp = self.client.post(reverse("order-cancel", args=[order.id]))

        self.assertEqual(resp.status_code, status.HTTP_200_OK, resp.data)
        self.assertEqual(resp.data["cancellation_reason"], None)

        order.refresh_from_db()
        self.assertIsNone(order.cancellation_reason)

        # No worker-delay alert fires for an unspecified cancellation.
        self.assertFalse(self.admin_user.notifications.exists())

    def test_cancel_due_to_other_reason_does_not_flag_worker_delay(self):
        order = self._accepted_order()

        self.client.force_authenticate(user=self.client_user)
        with patch("apps.orders.views.paymob.void_commission", return_value={}):
            resp = self.client.post(
                reverse("order-cancel", args=[order.id]),
                {"reason": Order.CANCELLATION_OTHER}, format="json",
            )

        self.assertEqual(resp.status_code, status.HTTP_200_OK, resp.data)
        self.assertEqual(resp.data["cancellation_reason"], Order.CANCELLATION_OTHER)
        self.assertFalse(self.admin_user.notifications.exists())

    def test_invalid_cancel_reason_is_rejected(self):
        order = self._accepted_order()

        self.client.force_authenticate(user=self.client_user)
        resp = self.client.post(
            reverse("order-cancel", args=[order.id]),
            {"reason": "MAYBE_DELAY"}, format="json",
        )

        self.assertEqual(resp.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn("error", resp.data)
        self.assertIn("reason", resp.data["error"])


class OrderAttachmentLimitTests(APITestCase):
    """Enforced limits: max 4 images + 1 audio note per order.

    The upload-after-creation path must count attachments already stored on
    the order, otherwise repeated uploads could stack files forever."""

    @classmethod
    def setUpTestData(cls):
        cls.category = ServiceCategory.objects.create(name="Plumbing")
        cls.client_user = User.objects.create_user(
            username="attach_client", phone="+201000000030",
            password="Sup3r-Secret!", role=User.Role.CLIENT,
            profile_completed=True,
        )
        cls.address = Address.objects.create(
            user=cls.client_user, label="Home",
            address="12 Test St", governorate="cairo", city="Nasr City",
        )

    def _files(self, n_images, n_audio):
        files = [
            SimpleUploadedFile(
                f"photo_{i}.jpg", b"fakejpeg", content_type="image/jpeg",
            )
            for i in range(n_images)
        ]
        files += [
            SimpleUploadedFile(
                f"voice_{i}.m4a", b"fakeaudio", content_type="audio/mp4",
            )
            for i in range(n_audio)
        ]
        return files

    def _post_create(self, files):
        self.client.force_authenticate(user=self.client_user)
        return self.client.post(
            reverse("order-list-create"),
            {
                "service_category": str(self.category.id),
                "address_id": str(self.address.id),
                "attachments": files,
            },
            format="multipart",
        )

    def test_order_with_five_images_is_rejected(self):
        with patch("apps.orders.views.authorize_commission", return_value="dummy_key"):
            resp = self._post_create(self._files(5, 0))
        self.assertEqual(resp.status_code, status.HTTP_400_BAD_REQUEST, resp.data)
        self.assertIn("attachments", resp.data)
        self.assertEqual(OrderAttachment.objects.count(), 0)

    def test_order_with_two_audio_notes_is_rejected(self):
        with patch("apps.orders.views.authorize_commission", return_value="dummy_key"):
            resp = self._post_create(self._files(0, 2))
        self.assertEqual(resp.status_code, status.HTTP_400_BAD_REQUEST, resp.data)
        self.assertIn("attachments", resp.data)
        self.assertEqual(OrderAttachment.objects.count(), 0)

    def test_upload_after_creation_exceeding_total_is_rejected(self):
        with patch("apps.orders.views.authorize_commission", return_value="dummy_key"):
            create_resp = self._post_create(self._files(2, 0))
        self.assertEqual(create_resp.status_code, status.HTTP_201_CREATED, create_resp.data)
        order = Order.objects.get(pk=create_resp.data["id"])
        self.assertEqual(order.attachments.count(), 2)

        # 2 stored + 3 new = 5 > 4 → must be rejected.
        self.client.force_authenticate(user=self.client_user)
        upload_resp = self.client.post(
            reverse("order-attachments", args=[order.id]),
            {"attachments": self._files(3, 0)},
            format="multipart",
        )
        self.assertEqual(upload_resp.status_code, status.HTTP_400_BAD_REQUEST, upload_resp.data)
        order.refresh_from_db()
        self.assertEqual(order.attachments.count(), 2)

    def test_order_with_exactly_four_images_passes(self):
        with patch("apps.orders.views.authorize_commission", return_value="dummy_key"):
            resp = self._post_create(self._files(4, 0))
        self.assertEqual(resp.status_code, status.HTTP_201_CREATED, resp.data)
        order = Order.objects.get(pk=resp.data["id"])
        self.assertEqual(order.attachments.count(), 4)
        self.assertEqual(
            order.attachments.filter(kind=OrderAttachment.KIND_IMAGE).count(),
            4,
        )
