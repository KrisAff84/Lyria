import boto3

session = boto3.Session(profile_name='kris84')
aws_s3_region_name = 'us-east-1'
buckets = {
    'lyria-storage-2024-dev': 'dev/songs/', 
    'lyria-storage-2024-prod': 'songs/'
}

s3 = session.client('s3', region_name=aws_s3_region_name)

song_name = input('Enter the name of the song you want to add (uses underscores for spaces and "*" for apostrophes): ')
audio_file = input('Enter the path to the audio file: ')
image_file = input('Enter the path to the image file: ')

for bucket, path in buckets.items():
    s3.put_object(Bucket=bucket, Key=f'{path}{song_name}/')
    s3.upload_file(audio_file, bucket, f'{path}{song_name}/audio_file.mp3', ExtraArgs={'ContentType': 'audio/mp3'})
    s3.upload_file(image_file, bucket, f'{path}{song_name}/image_file.jpg', ExtraArgs={'ContentType': 'image/jpg'})

    print(f'Song successfully added to {bucket}')