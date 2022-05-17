import os
import json

BROKER_URL = os.environ.get('CELERY_BROKER_URL', 'redis://redis:6379/1')
CELERY_RESULT_BACKEND = os.environ.get('CELERY_RESULT_BACKEND', 'redis://redis:6379/2')
CELERY_IMPORTS = ("tasks",)

CELERY_TASK_SERIALIZER = os.environ.get('CELERY_TASK_SERIALIZER', 'json')
CELERY_RESULT_SERIALIZER = os.environ.get('CELERY_RESULT_SERIALIZER', 'json')
CELERY_ACCEPT_CONTENT = json.loads(os.environ.get('CELERY_ACCEPT_CONTENT', '["json"]'))

CELERY_TIMEZONE = os.environ.get('CELERY_TIMEZONE', 'Europe/Moscow')
CELERY_ENABLE_UTC = os.environ.get('CELERY_ENABLE_UTC', 'true') == 'true'
