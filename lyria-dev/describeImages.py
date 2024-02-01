""" Obtains the latest version # of the AMI for the Lyria application.
    Used only for testing purposes.
"""
import boto3


ec2 = boto3.client(
    'ec2',
    region_name='us-east-2',
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
print(ami_version)
