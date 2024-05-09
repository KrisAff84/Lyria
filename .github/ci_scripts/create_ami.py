""" This script creates an AMI from the instance with the given instance_id.
    It first obtains the latest version of the AMI for the Lyria application and
    increments it by 1 to create a new version.
"""

import os
import boto3

access_key_id = os.environ.get('AWS_ACCESS_KEY_ID')
secret_access_key = os.environ.get('AWS_SECRET_ACCESS_KEY')
instance_id = os.environ.get('STAGING_INSTANCE_ID')
aws_region = os.environ.get('AWS_REGION')


ec2 = boto3.client(
    'ec2',
    region_name=aws_region,
    aws_access_key_id=access_key_id,
    aws_secret_access_key=secret_access_key  
)

response = ec2.describe_images(
    Owners=['self'],
    Filters=[
        {
            'Name': 'name',
            'Values': [
                'lyria_v*'
            ]
        }
    ]
)

version_numbers = []
for image in response['Images']:
    version_number = image['Name'][::-1][0]
    version_numbers.append(int(version_number))

ami_version = max(version_numbers)
ami_version += 1

response = ec2.create_image(
    InstanceId = instance_id,
    Name = f'lyria_v{ami_version}',
    TagSpecifications=[
        {
            'ResourceType': 'image',
            'Tags': [
                {
                    'Key': 'lyria',
                    'Value': ''
                },
            ]
        },
        {
            'ResourceType': 'snapshot',
            'Tags': [
                {
                    'Key': 'lyria',
                    'Value': f'v{ami_version}'
                },
            ]
        },
    ]
    
)

image_id = response['ImageId']
waiter = ec2.get_waiter('image_available')
waiter.wait(ImageIds=[image_id])

print(f'Image ID: {image_id}')
with open(os.environ['GITHUB_OUTPUT'], 'a') as output_file:
    output_file.write(f'image_id={image_id}\n')
