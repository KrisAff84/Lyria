from django.shortcuts import render
from django.conf import settings
import boto3
import random
from django.http import StreamingHttpResponse
import requests


def index(request):
    s3 = boto3.client('s3', region_name='us-east-2')
    song_list = []
    audio_file_list = []
    song_keys = []
    idx = 1
    bucket_name = "lyria-storage"
    response = s3.list_objects_v2(Bucket=bucket_name, Prefix='songs/')
    while idx < len(response['Contents']):
        song_keys.append(response['Contents'][idx]['Key'].split('/')[1])
        idx += 2

    for song in song_keys:
        response = s3.list_objects_v2(Bucket=bucket_name, Prefix=f'songs/{song}/audio_file.mp3')
        audio_file_list.append(f"{bucket_name}.s3.us-east-2.amazonaws.com/{response['Contents'][0]['Key']}")

    song_list = [song.replace('_', ' ') for song in song_keys]

    random_idx = random.randint(0, len(song_list) - 1)

    current_song_title = song_list[random_idx]
    current_song_audio_file = audio_file_list[random_idx]

    context = {
        'song_list': song_list,
        'audio_file_list': audio_file_list,
        'current_song_title': current_song_title,
        'current_song_audio_file': current_song_audio_file,
    }

    return render(request, 'index.html', context)


def play(request, current_song_audio_file):
    audio_file_url = f"https://{current_song_audio_file}"


    def audio_generator():
        chunk_size = 1024
        while True:
            chunk = requests.get(audio_file_url, stream=True).content
            if not chunk:
                break
            yield chunk
        
    

    response = StreamingHttpResponse(audio_generator(), content_type="audio/mp3")
    response['Access-Control-Allow-Origin'] = 'http://localhost:8000'
    response['Access-Control-Allow-Methods'] = 'GET'
    response['Access-Control-Allow-Headers'] = 'Accept, Accept-Encoding, Authorization, Content-Type, Origin, User-Agent'

    return response



def pause(request):
    pass


def skip_forward():
    pass


def skip_backward():
    pass