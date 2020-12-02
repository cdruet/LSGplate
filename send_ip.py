from email.header import Header
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
import binascii
import datetime
import fcntl
import hashlib
import math
import smtplib
import socket
import struct
import time
import traceback
import urllib
import requests

recipient = ""

GMAIL_USER = u''
GMAIL_PASS = u''
SMTP_SERVER = u'smtp.office365.com'
SMTP_PORT = 587
  
CONF_PATH = "/etc/lsgplate.conf"
LOG_PATH = "/var/log/send_ip.log"


def deflog(logname):
    log = logging.getLogger(logname)
    log.setLevel(logging.INFO)
    handler = TimedRotatingFileHandler(
                LOG_PATH,
                encoding='utf=8',
                when='D',
                interval=7,
                backupCount=8,
              )
    fmtr = logging.Formatter(
            "%(asctime)s - %(name)s - %(levelname)s - %(message)s"
           )
    handler.setFormatter(fmtr)
    log.addHandler(handler)

    return log


def load_data():
    conf = config.Config(
                CONF_PATH,
                defaults={
                    'plate_name': 'LSGplateID',
                },
             )

    data = persist.persist(
                PERSIST_PATH,
                {'id': shortuuid.uuid(),
                 'secret': str(shortuuid.uuid()) + str(shortuuid.uuid()) + str(shortuuid.uuid())},
           )

    return (conf, data)


def get_ip():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    s.connect(("8.8.8.8", 80))
    return s.getsockname()[0]
    

def send_ip(recipient, plate, ip, log):
    log.info("Trying to send IP to " + recipient + " about " + subject + " : " + text)
    try:
        subject = '{} IP address is {}'.format(plate, ip)
        
        smtpserver = smtplib.SMTP(SMTP_SERVER, SMTP_PORT)
        smtpserver.ehlo()
        smtpserver.starttls()
        smtpserver.ehlo
        smtpserver.login(GMAIL_USER, GMAIL_PASS)
        header = u'To:' + recipient + u'\n' + u'From: ' + GMAIL_USER
        header = header + '\n' + u'Subject:' + subject + u'\n'
        
        msg = MIMEMultipart('alternative')
        msg.set_charset('utf8')
        msg['From'] = GMAIL_USER
        msg['To'] = recipient
        msg['Subject'] = Header(subject.encode('utf-8'),
                                'UTF-8').encode()
        
        _attach = MIMEText(subject.encode('utf-8'), 'plain', 'UTF-8')
        msg.attach(_attach)
        
        smtpserver.sendmail(GMAIL_USER, recipient, msg.as_string())
        smtpserver.close()
        log.info("IP sent")
        return True
    except:
        traceback.print_exc()
    return False


def post_ip(plate, ip, log):
    log.info('Trying to post IP on dedicated webservice')
    try:
        url = 'https://webservices.stoachup.be/redirect/local/v1.0'
        data = { 'service': 'lsgplate',
                 'keyword': plate,
                 'local_ip': ip }
        
        x = requests.post(url, data=data)
        
        print(x.text)
        return True
    except:
        traceback.print_exc()
    return False


def main(log):
    log.info("Sending IP util successful")
    conf, data = load_data()
    ip = get_ip()
    while not send_ip(recipient, conf.plate_name, ip, log):
        time.sleep(60)


if __name__ == '__main__':
    log = deflog('send_ip')
    main(log)
