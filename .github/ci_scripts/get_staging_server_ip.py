""" This script waits for an instance to be in the 'ok' stat and then obtains the public IP """

import os
import boto3

access_key_id = os.environ.get('AWS_ACCESS_KEY_ID')
secret_access_key = os.environ.get('AWS_SECRET_ACCESS_KEY')
instance_id = 'i-01ee3032740fc3229'

ec2 = boto3.client(
    'ec2',
    region_name='us-east-2',
    aws_access_key_id=access_key_id,
    aws_secret_access_key=secret_access_key 
)

waiter = ec2.get_waiter('instance_status_ok')
waiter.wait(InstanceIds=[instance_id])

response = ec2.describe_instances(InstanceIds=[instance_id])

if 'PublicIpAddress' in response['Reservations'][0]['Instances'][0]:
    public_ip = response['Reservations'][0]['Instances'][0]['PublicIpAddress']
    print(f"Lyria Staging Instance is now running at: {public_ip}")
    with open(os.environ['GITHUB_OUTPUT'], 'a') as output_file:
        output_file.write(f'public_ip={public_ip}\n')
else:
    ipv6_address = response['Reservations'][0]['Instances'][0]['NetworkInterfaces'][0]['Ipv6Addresses'][0]['Ipv6Address']
    print(f"Lyria Staging Instance is now running at: {ipv6_address}")
    with open(os.environ['GITHUB_OUTPUT'], 'a') as output_file:
        output_file.write(f'public_ip={ipv6_address}\n')

