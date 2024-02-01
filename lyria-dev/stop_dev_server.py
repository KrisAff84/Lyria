import os
import boto3


access_key_id = os.environ.get('AWS_ACCESS_KEY_ID')
secret_access_key = os.environ.get('AWS_SECRET_ACCESS_KEY')
instance_id = os.environ.get('DEV_INSTANCE_ID')

ec2 = boto3.client(
    'ec2',
    region_name='us-east-2',
    aws_access_key_id=access_key_id,
    aws_secret_access_key=secret_access_key 
)

response = ec2.stop_instances(
    InstanceIds=[
        instance_id,
    ]
)
print("Dev Server Stopped")
