from django.urls import path

from . import views

urlpatterns = [
    path("home/", views.PublicHomeView.as_view(), name="site-home"),
    path("admin/site-config/", views.AdminSiteConfigView.as_view(), name="admin-site-config"),
]