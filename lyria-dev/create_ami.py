import boto3
import os

access_key_id = os.environ.get('AWS_ACCESS_KEY_ID')
secret_access_key = os.environ.get('AWS_SECRET_ACCESS_KEY')
instance_id = os.environ.get('DEV_INSTANCE_ID')

with open('ami_version.txt', 'r') as f:
    ami_version = int(f.read())

ami_version += 1

with open('ami_version.txt', 'w') as f:
    f.write(str(ami_version))

ec2 = boto3.client(
    'ec2', 
    region_name='us-east-2',
    aws_access_key_id=access_key_id,
    aws_secret_access_key=secret_access_key    
)

response = ec2.create_image(
    InstanceId = instance_id,
    Name = f'lyria_v{ami_version}',
)

image_id = response['ImageId']
waiter = ec2.get_waiter('image_available')
waiter.wait(ImageIds=[image_id])

print(f"::set-output name=image_id::{image_id}")


