#pylint: disable=C0116
"""Tests for the player app."""
from unittest.mock import patch, MagicMock
from django.test import TestCase
from django.test import Client
from django.conf import settings
# from player.views import index


class TestIndexView(TestCase):
    """Tests for the index view."""
    @patch('player.views.boto3.client')
    def test_index_view(self, mock_boto3_client):
        mock_s3_client = MagicMock()
        mock_boto3_client.return_value = mock_s3_client
        mock_s3_client.list_objects_v2.return_value = {
            'Contents': [
                {'Key': 'songs/'},
                {'Key': 'songs/Test_Song_1'},
                {'Key': 'songs/Test_Song_1/audio_file.mp3'},
                {'Key': 'songs/Test_Song_1/image_file.jpg'},
                {'Key': 'songs/Test_Song_2'},
                {'Key': 'songs/Test_Song_2/audio_file.mp3'},
                {'Key': 'songs/Test_Song_2/image_file.jpg'},
                {'Key': 'songs/Test_Song_3'},
                {'Key': 'songs/Test_Song_3/audio_file.mp3'},
                {'Key': 'songs/Test_Song_3/image_file.jpg'},
            ]
        }

        with patch.dict(settings.__dict__, {'AWS_STORAGE_BUCKET_NAME': 'test-bucket',
                                            'AWS_S3_REGION_NAME': 'us-east-2',
                                            'CLOUDFRONT_URL': 'test-cf-url-8732364',
                                            'SONG_ORDER': [0,1,2],  
                                            }):

            client = Client()
            response = client.get('')  # Replace '/your-url/' with your actual URL

            # Assert that the response is successful
            self.assertEqual(response.status_code, 200)

            # Assert that the rendered template is correct
            self.assertTemplateUsed(response, 'index.html')

            # Assert that the context contains the expected data
            self.assertIn('song_list', response.context)
            self.assertIn('audio_urls', response.context)
            self.assertIn('image_urls', response.context)
            self.assertIn('current_title', response.context)
            self.assertIn('current_audio_url', response.context)
            self.assertIn('current_image_url', response.context)
            self.assertIn('current_idx', response.context)
        print(settings.__dict__)
