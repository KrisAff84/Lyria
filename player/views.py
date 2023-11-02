from django.shortcuts import render
from django.conf import settings
import boto3
import json


# Don't need this function, purely for learning/testing
def say_hello(request):
    return render(request, 'hello.html', {'name': 'Kris'})

def index(request):
    s3 = boto3.client('s3')
    song_list = []
    audio_file_list = []
    idx = 1
    bucket_name = 'lyria-storage'
    response = s3.list_objects_v2(Bucket=bucket_name, Prefix='songs/')
    while idx < len(response['Contents']):
        song_list.append(response['Contents'][idx]['Key'].split('/')[1].replace('_', ' '))
        idx += 2
    song = song_list[0]
    context = {'song': song}

    return render(request, 'index.html', context)


def play(request, song):
    pass



def pause(request):
    pass


def skip_forward():
    pass


def skip_backward():
    pass