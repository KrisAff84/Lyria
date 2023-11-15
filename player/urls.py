from django.urls import path
from . import views


urlpatterns = [
    path('index/', views.index, name='index'),
    # path('play/<str:current_song_key>/', views.play, name='play')
]