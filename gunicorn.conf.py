# Install GUnicorn - pip install gunicorn
# Run - gunicorn -c gunicorn.conf.py lyria.wsgi:application

bind = "0.0.0.0:8000"
workers = 3
timeout = 60
module = "lyria.wsgi:application"
