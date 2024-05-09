""" This script deregisters either the oldest or most recent version of the Lyria
    application AMI. It runs from the workflow file DeregisterAmi.yml, and an input
    of either 'oldest' or 'latest' is provided.
"""

import boto3
import sys
import os


access_key_id = os.environ.get('AWS_ACCESS_KEY_ID')
secret_access_key = os.environ.get('AWS_SECRET_ACCESS_KEY')
aws_region = os.environ.get('AWS_REGION')
ami_version = sys.argv[1]

ec2 = boto3.client(
    'ec2',
    region_name='us-east-1',
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

if ami_version == 'oldest':
    ami_version_to_deregister = min(version_numbers)
else:
    ami_version_to_deregister = max(version_numbers)

response = ec2.describe_images(
    Owners=['self'],
    Filters=[
        {
            'Name': 'name',
            'Values': [
                f'lyria_v{ami_version_to_deregister}'
            ]
        }
    ]
)

ami_id = response['Images'][0]['ImageId']
snapshot_id = response['Images'][0]['BlockDeviceMappings'][0]['Ebs']['SnapshotId']

response = ec2.deregister_image(
    ImageId=ami_id
)

print(f'AMI {ami_id} (version {ami_version_to_deregister}) deregistered successfully')

response = ec2.delete_snapshot(
    SnapshotId=snapshot_id
)

print(f'Snapshot {snapshot_id} (for AMI version {ami_version_to_deregister}) deleted successfully')
