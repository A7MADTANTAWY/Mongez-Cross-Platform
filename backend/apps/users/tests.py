from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase

from .models import Address, User


class AuthFlowTests(APITestCase):
    def test_login_returns_tokens(self):
        User.objects.create_user(
            username="carol", phone="+201000000001", password="Sup3r-Secret!",
        )
        response = self.client.post(reverse("admin-login"), {
            "username": "carol", "password": "Sup3r-Secret!",
        }, format="json")
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn("access", response.data["tokens"])

    def test_login_with_bad_password_fails(self):
        User.objects.create_user(
            username="dave", phone="+201000000002", password="Sup3r-Secret!",
        )
        response = self.client.post(reverse("admin-login"), {
            "username": "dave", "password": "wrong",
        }, format="json")
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)


class CompleteProfileTests(APITestCase):
    """Test the actual auth flow: Google sign-in creates user →
    PATCH /api/auth/complete-profile/ sets profile fields."""

    def setUp(self):
        self.user = User.objects.create_user(
            username="new_user", phone="+201111111111",
            password="Sup3r-Secret!", profile_completed=False,
        )
        self.client.force_authenticate(user=self.user)

    def test_complete_profile_with_required_fields(self):
        response = self.client.patch(reverse("complete-profile"), {
            "phone": "+201112223344",
            "governorate": "cairo",
            "role": "worker",
        }, format="json")
        self.assertEqual(response.status_code, status.HTTP_200_OK, response.data)
        self.user.refresh_from_db()
        self.assertTrue(self.user.profile_completed)
        self.assertEqual(self.user.governorate, "cairo")

    def test_complete_profile_with_name_ar(self):
        response = self.client.patch(reverse("complete-profile"), {
            "phone": "+201112223355",
            "name_ar": "أحمد حسن",
            "governorate": "cairo",
            "city": "Nasr City",
            "role": "worker",
        }, format="json")
        self.assertEqual(response.status_code, status.HTTP_200_OK, response.data)
        self.user.refresh_from_db()
        self.assertEqual(self.user.name_ar, "أحمد حسن")
        self.assertEqual(self.user.city, "Nasr City")

    def test_complete_profile_rejects_unknown_governorate(self):
        response = self.client.patch(reverse("complete-profile"), {
            "phone": "+201112223388",
            "governorate": "atlantis",
            "role": "client",
        }, format="json")
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn("governorate", response.data)


class GovernoratesEndpointTests(APITestCase):
    """Endpoint that the mobile + dashboard hydrate their governorate
    dropdowns from."""

    def test_governorates_endpoint_returns_27_entries_with_arabic_names(self):
        response = self.client.get(reverse("governorates"))
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        body = response.data
        self.assertEqual(len(body), 27)
        cairo = next((g for g in body if g["code"] == "cairo"), None)
        self.assertIsNotNone(cairo)
        self.assertEqual(cairo["name_en"], "Cairo")
        self.assertEqual(cairo["name_ar"], "القاهرة")
        # Each row has all three fields.
        for g in body:
            self.assertIn("code", g)
            self.assertIn("name_en", g)
            self.assertIn("name_ar", g)


class DefaultAddressSyncTests(APITestCase):
    """Changing the user's default address must propagate to the User's
    public location fields — the source of what customers see on the
    worker card / details."""

    def setUp(self):
        self.user = User.objects.create_user(
            username="tech1",
            phone="+201000000011",
            password="Sup3r-Secret!",
            profile_completed=True,
            governorate="cairo",
            city="Nasr City",
            address="12 Old Cairo St",
        )
        # Mirror the app's complete-profile flow: the first saved address
        # reflects the user fields and is the default.
        Address.objects.create(
            user=self.user,
            label="Nasr City",
            address="12 Old Cairo St",
            governorate="cairo",
            city="Nasr City",
            is_default=True,
        )
        self.client.force_authenticate(self.user)

    def test_patching_default_address_updates_user_location(self):
        Address.objects.create(
            user=self.user,
            label="Office",
            address="5 Maadi St",
            governorate="giza",
            city="Maadi",
            is_default=False,
        )
        target = Address.objects.get(label="Office")
        url = reverse("address-detail", args=[target.pk])
        response = self.client.patch(url, {"is_default": True}, format="json")
        self.assertEqual(response.status_code, status.HTTP_200_OK, response.data)
        self.user.refresh_from_db()
        self.assertEqual(self.user.address, "5 Maadi St")
        self.assertEqual(self.user.city, "Maadi")
        self.assertEqual(self.user.governorate, "giza")

    def test_post_default_address_updates_user_location(self):
        url = reverse("address-list-create")
        response = self.client.post(url, {
            "label": "Work",
            "address": "3 Dokki St",
            "governorate": "giza",
            "city": "Dokki",
            "is_default": True,
        }, format="json")
        self.assertEqual(response.status_code, status.HTTP_201_CREATED, response.data)
        self.user.refresh_from_db()
        self.assertEqual(self.user.address, "3 Dokki St")
        self.assertEqual(self.user.city, "Dokki")
        self.assertEqual(self.user.governorate, "giza")

    def test_deleting_default_promotes_and_syncs(self):
        Address.objects.create(
            user=self.user,
            label="Office",
            address="5 Maadi St",
            governorate="giza",
            city="Maadi",
            is_default=False,
        )
        default = Address.objects.get(is_default=True)
        url = reverse("address-detail", args=[default.pk])
        response = self.client.delete(url)
        self.assertEqual(response.status_code, status.HTTP_204_NO_CONTENT, response.data)
        self.user.refresh_from_db()
        self.assertEqual(self.user.address, "5 Maadi St")
        self.assertEqual(self.user.city, "Maadi")
        self.assertEqual(self.user.governorate, "giza")

    def test_non_default_change_keeps_user_location(self):
        url = reverse("address-list-create")
        response = self.client.post(url, {
            "label": "Office",
            "address": "5 Maadi St",
            "governorate": "giza",
            "city": "Maadi",
            "is_default": False,
        }, format="json")
        self.assertEqual(response.status_code, status.HTTP_201_CREATED, response.data)
        self.user.refresh_from_db()
        self.assertEqual(self.user.city, "Nasr City")
        self.assertEqual(self.user.governorate, "cairo")
