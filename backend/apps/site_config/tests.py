from django.core.cache import cache
from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase

from apps.orders.models import Order
from apps.users.models import User
from apps.workers.models import ServiceCategory, WorkerProfile

from .models import SiteConfig


class PublicHomeTests(APITestCase):
    def setUp(self):
        cache.clear()

    def test_public_home_requires_no_auth(self):
        response = self.client.get(reverse("site-home"))
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn("config", response.data)
        self.assertIn("stats", response.data)

    def test_home_reports_live_counts(self):
        category = ServiceCategory.objects.create(name="Plumbing", name_ar="سباكة")
        client_user = User.objects.create_user(
            username="cli", password="Secret!23",
            role=User.Role.CLIENT, profile_completed=True,
        )
        worker_user = User.objects.create_user(
            username="wor", password="Secret!23",
            role=User.Role.WORKER, profile_completed=True,
        )
        WorkerProfile.objects.create(
            user=worker_user, profession="Plumbing", is_verified=True,
        )
        Order.objects.create(
            client=client_user, worker=worker_user,
            service_category=category, description="Leak", status=Order.COMPLETED,
        )

        response = self.client.get(reverse("site-home"))
        stats = response.data["stats"]
        self.assertEqual(stats["workers_count"], 1)
        self.assertEqual(stats["verified_workers_count"], 1)
        self.assertEqual(stats["completed_orders"], 1)
        self.assertEqual(stats["categories_count"], 1)

    def test_saved_config_is_served(self):
        config = SiteConfig.singleton()
        config.hotline_phone = "19019"
        config.save()
        response = self.client.get(reverse("site-home"))
        self.assertEqual(response.data["config"]["hotline_phone"], "19019")


class AdminSiteConfigTests(APITestCase):
    def setUp(self):
        cache.clear()
        self.admin = User.objects.create_user(
            username="admin", password="Secret!23", role=User.Role.ADMIN,
        )
        self.client_user = User.objects.create_user(
            username="cliff", password="Secret!23", role=User.Role.CLIENT,
        )

    def test_admin_can_update_config(self):
        self.client.force_authenticate(user=self.admin)
        response = self.client.put(
            reverse("admin-site-config"),
            {"hotline_phone": "19019", "support_email": "support@mongez.com"},
            format="json",
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK, response.data)
        config = SiteConfig.singleton()
        self.assertEqual(config.hotline_phone, "19019")
        self.assertEqual(config.support_email, "support@mongez.com")

    def test_admin_can_read_config(self):
        config = SiteConfig.singleton()
        config.instagram_url = "https://instagram.com/mongez"
        config.save()
        self.client.force_authenticate(user=self.admin)
        response = self.client.get(reverse("admin-site-config"))
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data["instagram_url"], "https://instagram.com/mongez")

    def test_non_admin_cannot_access(self):
        self.client.force_authenticate(user=self.client_user)
        response = self.client.get(reverse("admin-site-config"))
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)
        config_before = SiteConfig.singleton().hotline_phone
        update = self.client.put(
            reverse("admin-site-config"), {"hotline_phone": "9999"}, format="json",
        )
        self.assertEqual(update.status_code, status.HTTP_403_FORBIDDEN)
        self.assertEqual(SiteConfig.singleton().hotline_phone, config_before)

    def test_anonymous_cannot_update(self):
        response = self.client.put(
            reverse("admin-site-config"), {"hotline_phone": "9999"}, format="json",
        )
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)