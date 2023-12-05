import boto3

s3 = boto3.client('s3')
response = s3.list_objects_v2(Bucket='lyria-storage', Prefix='songs/')

for content in response['Contents']:
    print(content['Key'])