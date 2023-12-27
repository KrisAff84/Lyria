import boto3

access_key_id = '' # Add access key for testing environment
secret_access_key = ''# Add secret access key for testing environment

ec2 = boto3.client(
    'ec2', 
    region_name='us-east-2',
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
print(ami_version)
