import boto3

session = boto3.Session(profile_name='kris84')
aws_s3_region_name = 'us-east-1'
bucket_names = ['lyria-storage-2024-dev', 'lyria-storage-2024-prod']

s3 = session.client('s3', region_name=aws_s3_region_name)

song_name = input('Enter the name of the song you want to add (uses underscores for spaces and "*" for apostrophes): ')
audio_file = input('Enter the path to the audio file: ')
image_file = input('Enter the path to the image file: ')

for bucket_name in bucket_names:
    s3.put_object(Bucket=bucket_name, Key=f'songs/{song_name}/')
    s3.upload_file(audio_file, bucket_name, f'songs/{song_name}/audio_file.mp3')
    s3.upload_file(image_file, bucket_name, f'songs/{song_name}/image_file.jpg')

    print(f'Song added successfully to {bucket_name}')