FROM python:3.13-rc-slim-bookworm


RUN apt-get update -y \
    && apt-get install -y libturbojpeg0-dev libjpeg-dev liblzma-dev liblz-dev \
    && apt-get install make g++ -y \
    && apt-get install -y zlib1g-dev \
    && pip install --upgrade pip 

COPY requirements/docker-requirements.txt /Lyria/requirements.txt
RUN pip install -r /Lyria/requirements.txt

COPY . /Lyria

EXPOSE 80

WORKDIR /Lyria

CMD ["gunicorn", "-c", "gunicorn.conf.py", "lyria.wsgi:application"]
