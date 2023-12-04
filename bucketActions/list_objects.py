import boto3
import json

s3 = boto3.client('s3')
response = s3.list_objects_v2(Bucket='lyria-storage', Prefix='songs/')

print(json.dumps(response, indent=4, default=str))