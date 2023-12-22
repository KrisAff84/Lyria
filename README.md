# Lyria Music Player

This music player was built using Django. In addition to the actual Django project, this repository contains the following additional types of files:

    - Terraform files - for provisioning infrastructure on AWS
    - Docker files (Dockerfile, compose.yml, .dockerignore)
    - Configuration files (Nginx and GUnicorn)
    - bucketActions - boto3 scripts for easy bucket admin tasks

### Basic File Structure

- lyria
    - __init__.py
    - asgi.py
    - settings.py
    - urls.py
    - wsgi.py
- player
    - __init__.py
    - admin.py
    - apps.py
    - migrations
        - __init__.py
    - models.py
    - templates
        - index.html
    - tests.py
    - urls.py
    - views.py
- manage.py
- requirements.txt
- gunicorn.conf.py
- Dockerfile
- compose.yml
- .dockerignore
- terraform
    - main.tf
    - outputs.tf
    - providers.tf
    - variables.tf
- bucketActions
    - addSong.py
    - listObjectKeys.py
    - replaceFile.py
- nginx.conf
- .gitignore
- README.md

### .env File
A _.env_ file must be included in the root directory with the following environment variables:

- AWS_STORAGE_BUCKET_NAME
- AWS_S3_REGION_NAME
- CLOUDFRONT_URL
- SECRET_KEY (Django secret key)
- DEBUG (True or False)
- SONG_ORDER (list indexes)

For development you also need to include:

- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY

**Do not use your Admin user for these keys.** Create a user with read only access to your S3 bucket, and generate keys for that user. Include the _.env_ file in _.gitignore_. 

For production, use an IAM role instead of keys altogether. 