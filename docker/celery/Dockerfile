FROM python:latest

WORKDIR /app

RUN pip install --no-cache-dir \
        'celery[redis]>=4.0,<5.0' \
        beautifulsoup4 \
        'elasticsearch==8.2.0'

COPY docker/celery /app

ENTRYPOINT celery worker --pool=solo
