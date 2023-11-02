"""
This function obtains a list of all songs in the S3 bucket. It creates a separate list for ]
song titles and song audio files and then randomly selects a song title and its corresponding
audio file. The songs in the S3 bucket are stored in the following format:
<bucket_name>/songs/<song_title>/audio_file.mp3. In addition to the audio file, each 
song will also have a corresponding image file. 
"""


import boto3
import random

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


def main():
    index()


if __name__ == '__main__':
    main()