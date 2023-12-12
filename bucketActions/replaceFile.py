import boto3
from datetime import datetime

session = boto3.Session(profile_name='admin-profile')
aws_s3_region_name = 'us-east-2'
bucket_name = 'lyria-storage'

s3 = session.client('s3', region_name=aws_s3_region_name)
cloudfront = session.client('cloudfront')
print()
print("Current files the bucket: ")
print()
response = s3.list_objects_v2(Bucket=bucket_name, Prefix='songs/')

for content in response['Contents']:
    print(content['Key'])

bucket_key = input("Enter the bucket key you want to replace: ")
file_path = input("Enter the path to the new file: ")

s3.delete_object(Bucket=bucket_name, Key=bucket_key)
s3.upload_file(file_path, bucket_name, bucket_key)
print('File replaced successfully')

cloudfront.create_invalidation(
    DistributionId='E3GHN5TVQEVZ3J',
    InvalidationBatch= {
        'Paths': {
            'Quantity': 1,
            'Items': [
                f"/{bucket_key}",
            ]
        },
        'CallerReference': str(datetime.timestamp(datetime.now()))
    }
)

print('Cloudfront cache invalidated successfully')