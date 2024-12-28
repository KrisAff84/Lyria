#pylint: disable=C0116
"""Tests for the player app."""
from unittest.mock import patch, MagicMock
from django.test import TestCase
from django.test import Client
from django.conf import settings

CLOUDFRONT_URL = settings.CLOUDFRONT_URL
class TestIndexView(TestCase):
    """Tests for the index view
    1. Tests that the song list, audio urls, and image urls are populated correctly.
    2. Tests that the context contains the expected data.
    """

    mock_s3_contents = {
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

    mock_dynamo_db_contents = {
        'Items': [
            {
                'song_order': {'S': '0,1,2'},
            }
        ]
    }


    def setUp(self):
        super().setUp()
        self.mock_boto3_client = patch('player.views.boto3.client').start()
        self.mock_s3_client = MagicMock()
        self.mock_dynamo_db_client = MagicMock()
        self.mock_boto3_client.side_effect = lambda service_name, **kwargs: (
            self.mock_dynamo_db_client if service_name == 'dynamodb' else self.mock_s3_client
        )
        self.mock_s3_client.list_objects_v2.return_value = self.mock_s3_contents
        self.mock_dynamo_db_client.scan.return_value = self.mock_dynamo_db_contents

        # Set custom song order
        # patch.dict(settings.__dict__, {'song_order_string': [0, 1, 2]}).start()

    def tearDown(self):
        super().tearDown()
        patch.stopall()

    def test_populate_lists(self):
        """Tests that the song list, audio urls, and image urls are populated correctly."""
        client = Client()
        response = client.get('')  # Replace '/your-url/' with your actual URL

        self.assertListEqual(response.context['song_list'], ['Test Song 1', 'Test Song 2', 'Test Song 3'])
        self.assertListEqual(response.context['audio_urls'], [f'https://{CLOUDFRONT_URL}/songs/Test_Song_1/audio_file.mp3', f'https://{CLOUDFRONT_URL}/songs/Test_Song_2/audio_file.mp3', f'https://{CLOUDFRONT_URL}/songs/Test_Song_3/audio_file.mp3'])
        self.assertListEqual(response.context['image_urls'], [f'https://{CLOUDFRONT_URL}/songs/Test_Song_1/image_file.jpg', f'https://{CLOUDFRONT_URL}/songs/Test_Song_2/image_file.jpg', f'https://{CLOUDFRONT_URL}/songs/Test_Song_3/image_file.jpg'])

    def test_context_contains_expected_data(self):
        """Tests that the context contains the expected data."""
        client = Client()
        response = client.get('')
        self.assertIn('song_list', response.context)
        self.assertIn('audio_urls', response.context)
        self.assertIn('image_urls', response.context)
        self.assertIn('current_title', response.context)
        self.assertIn('current_audio_url', response.context)
        self.assertIn('current_image_url', response.context)
        self.assertIn('current_idx', response.context)

        # Assert that the response is successful
        # self.assertEqual(response.status_code, 200)

        # # Assert that the rendered template is correct
        # self.assertTemplateUsed(response, 'index.html')
