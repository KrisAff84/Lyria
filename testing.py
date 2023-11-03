"""
The index function obtains a list of all songs in the S3 bucket. It creates a separate list for ]
song titles and song audio files and then randomly selects a song title and its corresponding
audio file. The songs in the S3 bucket are stored in the following format:
<bucket_name>/songs/<song_title>/audio_file.mp3. In addition to the audio file, each 
song will also have a corresponding image file. 

The play function will play the current song. 
"""


import boto3
import random
import pygame
from io import BytesIO

def index():
    s3 = boto3.client('s3', region_name='us-east-2')
    song_list = []
    audio_file_list = []
    song_keys = []
    idx = 1
    bucket_name = 'lyria-storage'
    response = s3.list_objects_v2(Bucket=bucket_name, Prefix='songs/')
    while idx < len(response['Contents']):
        song_keys.append(response['Contents'][idx]['Key'].split('/')[1])
        idx += 2

    for song in song_keys:
        response = s3.list_objects_v2(Bucket=bucket_name, Prefix=f'songs/{song}/audio_file.mp3')
        audio_file_list.append(response['Contents'][0]['Key'])

    song_list = [song.replace('_', ' ') for song in song_keys]

    random_idx = random.randint(0, len(song_list) - 1)

    current_song_title = song_list[random_idx]
    current_song_audio_file = audio_file_list[random_idx]

    print(random_idx)
    print(song_keys)
    print()
    print(song_list)
    print()
    print(audio_file_list)
    print()
    print(current_song_title)
    print(current_song_audio_file)

    return current_song_audio_file


def play(current_song_audio_file):
    s3 = boto3.client('s3', region_name='us-east-2')
    bucket_name = 'lyria-storage'
    object_key = current_song_audio_file

    response = s3.get_object(Bucket=bucket_name, Key=object_key)
    audio_stream = response['Body']
    temp_file = BytesIO()
    chunk_size = 1024

    while True:
        chunk = audio_stream.read(chunk_size)
        if not chunk:
            break
        temp_file.write(chunk)
    
    temp_file.seek(0)

    pygame.mixer.init()
    pygame.mixer.music.load(temp_file)
    pygame.mixer.music.play()

    while pygame.mixer.music.get_busy():
        pygame.time.Clock().tick(10)

    audio_stream.close()


def main():
    current_song_audio_file = index()
    play(current_song_audio_file)


if __name__ == '__main__':
    main()
    