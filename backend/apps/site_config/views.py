from django.core.cache import cache
from django.db.models import Avg, Count
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.orders.models import Order
from apps.ratings.models import Rating
from apps.users.models import User
from apps.workers.models import ServiceCategory, WorkerProfile

from .models import SiteConfig
from .serializers import SiteConfigSerializer

_HOME_CACHE_KEY = "site_config:public_home:v1"
_HOME_CACHE_TTL = 30


def _home_payload():
    """Real, database-backed numbers for the landing page — never guessed."""
    rating_agg = Rating.objects.aggregate(avg=Avg("stars"), count=Count("id"))
    return {
        "config": SiteConfigSerializer(SiteConfig.singleton()).data,
        "stats": {
            "workers_count": WorkerProfile.objects.count(),
            "verified_workers_count": WorkerProfile.objects.filter(is_verified=True).count(),
            "completed_orders": Order.objects.filter(status=Order.COMPLETED).count(),
            "categories_count": ServiceCategory.objects.count(),
            "average_rating": round(rating_agg["avg"] or 0, 1),
            "rating_count": rating_agg["count"],
        },
    }


class PublicHomeView(APIView):
    """Public payload powering the landing page (config + live stats)."""

    permission_classes = [AllowAny]

    def get(self, request):
        cached = cache.get(_HOME_CACHE_KEY)
        if cached is None:
            cached = _home_payload()
            cache.set(_HOME_CACHE_KEY, cached, _HOME_CACHE_TTL)
        return Response(cached)


class AdminSiteConfigView(APIView):
    """Admin-only read/write for the site configuration."""
    permission_classes = [IsAuthenticated]

    def _is_admin(self, request):
        return request.user.role == User.Role.ADMIN

    def get(self, request):
        if not self._is_admin(request):
            return Response({"error": "Admin access required."}, status=403)
        return Response(SiteConfigSerializer(SiteConfig.singleton()).data)

    def put(self, request):
        if not self._is_admin(request):
            return Response({"error": "Admin access required."}, status=403)
        config = SiteConfig.singleton()
        serializer = SiteConfigSerializer(config, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        cache.delete(_HOME_CACHE_KEY)
        return Response(serializer.data)