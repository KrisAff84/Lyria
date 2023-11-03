from django.urls import path
from . import views


urlpatterns = [
    path('index/', views.index, name='index'),
    path('play/<str:current_song_audio_file>/', views.play, name='play')
]