from django.db import models



class Song(models.Model):
    title = models.CharField(max_length=200)
    image = models.ImageField()
    audio_file = models.FileField(default='')
    duration = models.CharField(max_length=200)
    file_type = models.CharField(max_length=200)
    is_favorite = models.BooleanField(default=False)

    def __str__(self):
        return self.title 
