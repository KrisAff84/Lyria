'''
Script used to configure the song order in the Lyria playlist. Zero based index.
Script will prompt for the song order. Separate indexes by comma and press enter to continue.
'''

import boto3
from invalidate_cache import invalidate_cloudfront_cache

session = boto3.Session(profile_name='kris84')

# print(f"Song order: {song_order}")

dynamodb = session.client('dynamodb')
response = dynamodb.scan(
    TableName='lyria_song_order'
)

old_song_order = response['Items'][0]['song_order']['S']
print(f"Old song order: {old_song_order}")
proceed = input("Are you sure you want to update the song order? (y/n) ")


if proceed == 'y':
    new_song_order = input("Enter the new song order. Separate indexes by comma:")
    dynamodb.delete_item(
        TableName='lyria_song_order',
        Key={
            'song_order': {
                'S': old_song_order
            }
        }
    )

    dynamodb.put_item(
        TableName='lyria_song_order',
        Item={
            'song_order': {
                'S': new_song_order
            }
        }
    )
    print("Song order updated.")

    invalidate_cloudfront_cache('E3RDP7Z44PB9L6')


else:
    print("Song order not updated. Exiting...")

