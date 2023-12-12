import boto3

session = boto3.Session(profile_name='admin-profile')
s3 = session.client('s3')
response = s3.list_objects_v2(Bucket='lyria-storage', Prefix='songs/')

for content in response['Contents']:
    print(content['Key'])