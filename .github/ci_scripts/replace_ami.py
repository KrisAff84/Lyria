import boto3
import sys
import os

access_key_id = os.environ.get('AWS_ACCESS_KEY_ID')
secret_access_key = os.environ.get('AWS_SECRET_ACCESS_KEY')
aws_region = os.environ.get('AWS_REGION')
ami_variable_line_number = 44
deployment_environment = sys.argv[1]
path_to_variables_file = f'../../terraform/{deployment_environment}/variables.tf'

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

latest_ami_version = max(version_numbers)

response = ec2.describe_images(
    Owners=['self'],
    Filters=[
        {
            'Name': 'name',
            'Values': [
                f'lyria_v{latest_ami_version}'
            ]
        }
    ]
)

latest_ami_id = response['Images'][0]['ImageId']

with open(path_to_variables_file, 'r') as f:
    lines = f.readlines()

lines[int(ami_variable_line_number) - 1] = f'  description = "lyria_v{latest_ami_version} image" \n'
lines[int(ami_variable_line_number)] = f'  default     = "{latest_ami_id}" \n'

with open(path_to_variables_file, 'w') as f:
    f.writelines(lines)

print(f"Lyria AMI changed to version {latest_ami_version} | AMI ID: {latest_ami_id}")

with open(os.environ['GITHUB_OUTPUT'], 'a') as output_file:
    output_file.write(f'latest_ami_version={latest_ami_version}\n')
    output_file.write(f'latest_ami_id={latest_ami_id}\n')
