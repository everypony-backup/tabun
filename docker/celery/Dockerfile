FROM python:latest
WORKDIR /app

RUN pip install --no-cache-dir \
        'celery[redis]>=4.0,<5.0' \
        beautifulsoup4 \
        'elasticsearch>=6.0,<7.0'

WORKDIR /app
COPY celery_tasks /app
COPY docker/celery/celeryconfig.py /app/celeryconfig.py