import os
from datetime import datetime
import boto3

session = boto3.Session(profile_name='kris84')
cloudfront = session.client('cloudfront')
ec2 = session.client('ec2')
distribution = os.getenv("DISTRIBUTION")
image_id = os.getenv("IMAGE_ID")

# Needs a waiter to determine if instance with new image ID is running. Currently, it sees terminated instances
# in the instance_exists waiter. But no instances are returned from the describe_instances call.
print(f'Waiting for instance(s) with new image ID ({image_id}) to be running...')

instance_running = ec2.get_waiter('instance_running')
instance_running.wait(
    Filters=[
        {
            'Name': 'image-id',
            'Values': [
                image_id,
            ]
        },
        {
            'Name': 'instance-state-name',
            'Values': [
                'running',
                'pending'
            ]
        }
    ]
)

response = ec2.describe_instances(
    Filters= [
        {
            'Name': 'image-id',
            'Values': [
                image_id,
            ]
        },
        {
            'Name': 'instance-state-name',
            'Values': [
                'running',
                'pending'
            ]
        }
    ]
)

instance_ids = [instance['InstanceId'] for reservation in response['Reservations'] for instance in reservation['Instances']]

print(f'Waiting for the status of instances {instance_ids} to be OK...')
instance_status_ok = ec2.get_waiter('instance_status_ok')
instance_status_ok.wait(
    InstanceIds=instance_ids
)

print(f'The status of instance(s) {instance_ids} is OK')
print('Invalidating Cloudfront cache...')

response = cloudfront.create_invalidation(
    DistributionId=distribution,
    InvalidationBatch= {
        'Paths': {
            'Quantity': 1,
            'Items': [
                "/*",
            ]
        },
        'CallerReference': str(datetime.timestamp(datetime.now()))
    }
)

invalidation_id = response['Invalidation']['Id']

invalidated = cloudfront.get_waiter('invalidation_completed')
invalidated.wait(
    DistributionId=distribution,
    Id=invalidation_id
)

print('Cloudfront cache invalidated successfully')