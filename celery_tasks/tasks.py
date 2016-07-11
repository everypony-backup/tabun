import smtplib
from celery.decorators import task
from email.header import Header
from email.utils import formataddr
from email.utils import formatdate
from email.utils import COMMASPACE
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from bs4 import BeautifulSoup
from elasticsearch import Elasticsearch

es = Elasticsearch()

@task
def send_mail(**kwargs):
    recipients = kwargs.get('recipients')

    from_email = kwargs.get('from_email')
    from_name = kwargs.get('from_name')

    subject = kwargs.get('subject')
    body = kwargs.get('body')

    is_html = kwargs.get('is_html')

    message = MIMEMultipart('alternative')

    message['Date'] = formatdate(localtime=1)
    message['Subject'] = Header(subject, 'utf-8')
    message['From'] = formataddr([from_name, from_email])
    message['To'] = COMMASPACE.join(map(formataddr, recipients))

    soup = BeautifulSoup(body)
    plain_body = soup.getText()

    part1 = MIMEText(plain_body.encode('utf-8'), 'plain', 'utf-8')
    message.attach(part1)

    if is_html:
        part2 = MIMEText(body.encode('utf-8'), 'html', 'utf-8')
        message.attach(part2)

    server = smtplib.SMTP('127.0.0.1', 1025)
    server.sendmail(
        from_email,
        [pair[1] for pair in recipients],
        message.as_string()
    )
    server.quit()

@task
def topic_index(**kwargs):
    index = kwargs.get('index')
    key = kwargs.get('key')
    topic_id = kwargs.get('topic_id')
    topic_blog_id = kwargs.get('topic_blog_id')
    topic_user_id = kwargs.get('topic_user_id')
    topic_type = kwargs.get('topic_type')
    topic_title = kwargs.get('topic_title')
    topic_text = kwargs.get('topic_text')
    topic_tags = kwargs.get('topic_tags')
    topic_date = kwargs.get('topic_date')
    topic_publish = kwargs.get('topic_publish')

    topic_tags = topic_tags.split(',')

    es.index(index=index, doc_type=key, id=int(topic_id), body=
        {
            'blog_id': int(topic_blog_id),
            'user_id': int(topic_user_id),
            'type': topic_type,
            'title': topic_title.strip(),
            'text': topic_text.strip(),
            'tags': topic_tags,
            'date': topic_date,
            'publish': topic_publish
        })

    print("Called!")
