from django.shortcuts import render
from django.conf import settings
import boto3
from django.http import StreamingHttpResponse, HttpResponse 
from botocore.config import Config


bucket_name = settings.AWS_STORAGE_BUCKET_NAME
aws_s3_region_name = settings.AWS_S3_REGION_NAME
aws_access_key_id = settings.AWS_ACCESS_KEY_ID
aws_secret_access_key = settings.AWS_SECRET_ACCESS_KEY
cloudfront_url = settings.CLOUDFRONT_URL

def index(request):
    
    s3 = boto3.client(
        's3', 
        region_name=aws_s3_region_name, 
        aws_access_key_id=aws_access_key_id,
        aws_secret_access_key=aws_secret_access_key,
        )

    title_keys = [] # song list with underscores
    song_list = [] # Song list without underscores
    audio_urls = [] # complete object keys with folder and file name
    image_urls = [] # Path to images

    idx = 1
    
    response = s3.list_objects_v2(Bucket=bucket_name, Prefix='songs/')

    # Gets list of song keys without folder name
    while idx < len(response['Contents']):
        # puts song titles with underscores into song_key list
        title_keys.append(response['Contents'][idx]['Key'].split('/')[1])
        idx += 1
        # puts path to complete audio file object urls into audio_urls list
        audio_urls.append(cloudfront_url + response['Contents'][idx]['Key'])
        idx += 1
        # puts path to complete image object urls into image_urls list
        image_urls.append(cloudfront_url + response['Contents'][idx]['Key'])
        idx += 1

    
    # Replaces underscores with spaces in title_keys list
    song_list = [song.replace('_', ' ') for song in title_keys]

    current_idx = 0

    current_title = song_list[current_idx]
    current_audio_url = audio_urls[current_idx]
    current_image_url = image_urls[current_idx]


    context = {
        'song_list': song_list,
        'audio_urls': audio_urls,
        'image_urls': image_urls,
        'current_title': current_title,
        'current_audio_url': current_audio_url,
        'current_image_url': current_image_url,
        'current_idx': current_idx,
    }

    return render(request, 'index.html', context)


# def play(request, current_song_key):
#     s3 = boto3.client(
#         's3', 
#         region_name='us-east-2', 
#         aws_access_key_id=aws_access_key_id,
#         aws_secret_access_key=aws_secret_access_key
#     )

#     presigned_url = s3.generate_presigned_url(
#             'get_object',
#             Params={
#                 'Bucket': bucket_name,
#                 'Key': current_song_key,
#             },
#             ExpiresIn=600,
#         )

#     def audio_generator():
#         chunk_size = 1024
#         response = requests.get(presigned_url, stream=True)
#         for chunk in response.iter_content(chunk_size=chunk_size):
#             if chunk:
#                 yield chunk
        
#     response = StreamingHttpResponse(audio_generator(), content_type="audio/mp3")
#     response['Access-Control-Allow-Origin'] = 'http://localhost:8000'
#     response['Access-Control-Allow-Methods'] = 'GET', 'HEAD'
#     response['Access-Control-Allow-Headers'] = 'Accept, Accept-Encoding, Authorization, Content-Type, Origin, User-Agent'

#     return response


def pause(request):
    pass


def skip_forward():
    pass


def skip_backward():
    pass