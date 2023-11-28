FROM python:3.13-rc-slim-bookworm

COPY . /Lyria

RUN apt-get update -y \
    && apt-get install -y libturbojpeg0-dev libjpeg-dev liblzma-dev liblz-dev \
    && apt-get install make g++ -y \
    && apt-get install -y zlib1g-dev \
    && pip install --upgrade pip \
    && pip install -r /Lyria/requirements.txt

EXPOSE 80

WORKDIR /Lyria

CMD ["python", "manage.py", "runserver", "0.0.0.0:80"]
