import os
import sys
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

from helpers import deflog, load_data, get_ip

recipient = ""

GMAIL_USER = u''
GMAIL_PASS = u''
SMTP_SERVER = u'smtp.office365.com'
SMTP_PORT = 587
  
CONF_PATH = "/etc/lsgplate.conf"
PERSIST_PATH = "/var/lib/lsgplate/lsgplate.json"
LOG_PATH = "/var/log/send_ip.log"


def send_ip(conf, ip, log):
    if GMAIL_USER == '' or GMAIL_PASS == '':
        log.error('Connection to SMTP cannot be configured by lack of user/password')
        return False
    log.info('Trying to send IP ({}) to {}'.format(ip, conf.recipient))
    try:
        subject = '{} IP address is {}'.format(conf.plate_name, ip)
        
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
        msg['To'] = conf.recipient
        msg['Subject'] = Header(subject.encode('utf-8'),
                                'UTF-8').encode()
        
        _attach = MIMEText(subject.encode('utf-8'), 'plain', 'UTF-8')
        msg.attach(_attach)
        
        smtpserver.sendmail(GMAIL_USER, conf.recipient, msg.as_string())
        smtpserver.close()
        log.info("IP sent")
        return True
    except:
        traceback.print_exc()
    return False


def main(log):
    log.info("Sending IP...")
    conf, data = load_data(CONF_PATH, PERSIST_PATH)
    ip = get_ip()
    if send_ip(conf, ip, log):
        log.info('IP ({}) successfully sent'.format(ip))
        sys.exit(os.EX_OK)
    else:
        log.warn('Failed to send IP ({})'.format(ip))
        sys.exit(1)


if __name__ == '__main__':
    log = deflog('send_ip', LOG_PATH)
    main(log)
