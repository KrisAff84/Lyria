"""Contains the views for the player app."""
from django.shortcuts import render
from django.conf import settings
from django.http import HttpResponse
import boto3


bucket_name = settings.AWS_STORAGE_BUCKET_NAME
aws_s3_region_name = settings.AWS_S3_REGION_NAME
cloudfront_url = settings.CLOUDFRONT_URL

def index(request):
    """Renders the index page.
    A boto3 list_objects_v2 call is made to get the list of song keys from the S3 bucket.
    The song keys are then used to create a list of song titles and a list of complete object keys.
    The object keys used to create a list of image and audio urls with a CloudFront distibution 
    placed in front of each URL.
    The song list, audio urls, and image urls are then passed to the index.html template.
    """
    s3 = boto3.client(
        's3', 
        region_name=aws_s3_region_name,
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

    song_order = settings.SONG_ORDER
    song_list = [song_list[i] for i in song_order]
    audio_urls = [audio_urls[i] for i in song_order]
    image_urls = [image_urls[i] for i in song_order]

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

def health_check(request):
    """Returns a 200 status code to indicate the server is running."""
    return HttpResponse("OK", status=200)
