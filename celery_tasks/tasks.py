import smtplib
from celery.decorators import task
from email.header import Header
from email.utils import formataddr
from email.utils import formatdate
from email.utils import COMMASPACE
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from bs4 import BeautifulSoup


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

