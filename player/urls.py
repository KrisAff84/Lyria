"""URLs for the player app."""
from django.urls import path
from .views import index 
from .views import health_check


urlpatterns = [
    path('', index, name='index'),
    path('health/', health_check, name='health_check'),
]
