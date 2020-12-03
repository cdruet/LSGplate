import datetime
import fcntl
import hashlib
import math
import smtplib
import socket
import traceback
import requests

  
from comitup import config
from comitup import persist


CONF_PATH = "/etc/lsgplate.conf"
LOG_PATH = "/var/log/post_ip.log"


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
    

def post_ip(conf, ip, log):
    log.info('Trying to post IP on dedicated webservice')
    try:
        url = conf.registering_service
        data = { 'api_key': conf.api_key, 
                 'application': 'lsgplate',
                 'keyword': conf.plate_name,
                 'local_ip': ip }
        
        r = requests.post(url, data=data)
        print(r.json())
        return True
    except:
        traceback.print_exc()
    return False


def main(log):
    log.info('Sending IP...')
    conf, data = load_data()
    ip = get_ip()
    count = 0
    max_attempt = 30
    while count < max_attempt and not post_ip(conf, ip, log):
        count += 1
        log.warning('Attempt #{} failed. Trying again in 10 seconds.'.format(count))
        time.sleep(10)


if __name__ == '__main__':
    log = deflog('send_ip')
    main(log)
