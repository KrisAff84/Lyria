# Lyria Music Player

This music player was built using Django. In addition to the actual Django project, this repository contains the following additional types of files:

- Terraform files - for provisioning infrastructure on AWS
- Docker files (Dockerfile, compose.yml, .dockerignore)
- Configuration files (Nginx and GUnicorn)
- bucketActions - boto3 scripts for easy bucket admin tasks
- CI/CD pipeline (GitHub Actions) - workflow files in .github/workflows with scripts in ci_scripts/

## Basic File Structure

- .github
    - workflows
        - RunContainers.yml
        - CreateImage.yml
- bucketActions
    - addSong.py
    - listObjectKeys.py
    - replaceFile.py
- ci_scripts
    - create_ami.py
    - create_env.py
    - get_staging_server_ip.py
    - start_staging_server.py
    - stop_staging_server.py  
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
- requirements
    - ci-requirements.txt
    - docker-requirements.txt
- terraform
    - blue
        - main.tf
        - outputs.tf
        - providers.tf
        - variables.tf
    - dns_records
        - main.tf
        - providers.tf
        - variables.tf
    - green
        - main.tf
        - outputs.tf
        - providers.tf
        - variables.tf
    - README.md
    - main.tf
    - outputs.tf
    - providers.tf
    - variables.tf
- manage.py
- requirements.txt
- gunicorn.conf.py
- Dockerfile
- compose.yml
- .dockerignore
- nginx.conf
- .gitignore
- README.md

## .env File
For local development, an _.env_ file must be included in the root directory with the following environment variables:

- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY
- AWS_STORAGE_BUCKET_NAME
- AWS_S3_REGION_NAME
- CLOUDFRONT_URL
- SECRET_KEY (Django secret key)
- DEBUG (True or False)
- SONG_ORDER (list indexes)

**DO NOT COMMIT THIS FILE**. Include the .env file in .gitignore

**DO NOT USE YOUR ADMIN USER FOR AWS KEYS.** Create a user with read only access to your S3 bucket, and generate keys for that user.  

For production, use an **IAM role** instead of keys altogether.

## Environment Variables in CI Pipeline
The following environment variables must be included in the GitHub repository secrets:
- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY
- SECRET_KEY

    - The AWS keys are separate from the ones used in the .env file. These keys are for the CI/CD pipeline to start and stop a staging server, as well as create and tag images. The policy should look like this:
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "ec2:StartInstances",
                "ec2:CreateTags",
                "ec2:CreateImage",
                "ec2:StopInstances",
                "ec2:DescribeInstanceStatus"
            ],
            "Resource": "arn:aws:ec2:us-east-2:<aws_account_number>:instance/<instance_id>"
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeInstances",
                "ec2:DescribeInstanceStatus",
                "ec2:CreateImage",
                "ec2:DescribeImages",
                "ec2:CreateTags"
            ],
            "Resource": "*"
        }
    ]
}
```
A .env file is created in the CI/CD pipeline to start containers on a running instance, then removed after the containers are running. Fill in environment variables in **RunContainers.yml** and **CreateImage.yml**.

## Infrastructure configured ouside of Terraform
**AWS S3 Bucket**: For storing music files

    Folder structure
        - songs
            - Song_Title_1
                - audio_file.mp3
                - image_file.mp3
            - Song_Title_2
                - audio_file.mp3
                - image_file.mp3

**CloudFront Distribution**: For serving audio and image files from storage bucket

**SSL Certificate** from AWS ACM

**Domain name** from AWS Route53

## Basic Development Workflow ##

1. Django is is developed locally, using the actual S3 bucket that will be used in production
2. Docker is used to containerize the application with further testing
3. CI Pipeline is used to build an AMI with running containers
4. New AMI is used to update launch template in the Terraform configuration

These are very broad steps, but generally show a user how to use this repository to build and customize Lyria the way I did.

### Article Links
I have not documented this entire project, but I do a few articles documenting key aspects. I will try to add more in the future.

[Broad Overview of Entire Project](https://medium.com/towards-aws/a-convergence-of-devops-tools-leveraging-django-docker-terraform-and-aws-to-build-a-custom-902733aaed8f)

