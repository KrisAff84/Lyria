import boto3

session = boto3.Session(profile_name='admin-profile')
aws_s3_region_name = 'us-east-2'
bucket_name = 'lyria-storage'

s3 = session.client('s3', region_name=aws_s3_region_name)

song_name = input('Enter the name of the song you want to add(separate words with underscores): ')
audio_file = input('Enter the path to the audio file: ')
image_file = input('Enter the path to the image file: ')

s3.put_object(Bucket=bucket_name, Key=f'songs/{song_name}/')
s3.upload_file(audio_file, bucket_name, f'songs/{song_name}/audio_file.mp3')
s3.upload_file(image_file, bucket_name, f'songs/{song_name}/image_file.jpg')

print('Song added successfully')