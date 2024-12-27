""" This script creates a .env file to copy to the staging server in the CI pipeline """

import os

env_file = '../../.env'
envs = {
    'AWS_STORAGE_BUCKET_NAME': os.environ.get('AWS_STORAGE_BUCKET_NAME'),
    'AWS_S3_REGION_NAME': os.environ.get('AWS_S3_REGION_NAME'),
    'CLOUDFRONT_URL': os.environ.get('CLOUDFRONT_URL'),
    'SECRET_KEY': f"'{os.environ.get('SECRET_KEY')}'",
}

with open(env_file, 'x') as f:
    for key, value in envs.items():
        f.write(f'{key}={value}\n')