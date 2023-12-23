import boto3
import os


access_key_id = os.environ.get('AWS_ACCESS_KEY_ID')
secret_access_key = os.environ.get('AWS_SECRET_ACCESS_KEY')
instance_id = os.environ.get('DEV_INSTANCE_ID')

ec2 = boto3.client(
    'ec2', 
    region_name='us-east-2',
    aws_access_key_id=access_key_id,
    aws_secret_access_key=secret_access_key    
)

start_instance = ec2.start_instances(
    InstanceIds=[
        instance_id,
    ]
)

waiter = ec2.get_waiter('instance_running')
waiter.wait(InstanceIds=[instance_id])
response = ec2.describe_instances(InstanceIds=[instance_id])
public_ip = response['Reservations'][0]['Instances'][0]['PublicIpAddress']
print(f"Lyria Dev Instance is now running at: {public_ip}")