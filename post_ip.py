import os
import sys
import time
import json
import traceback
import requests

from helpers import deflog, load_data, get_ip

CONF_PATH = "/etc/lsgplate.conf"
PERSIST_PATH = "/var/lib/lsgplate/lsgplate.json"
LOG_PATH = "/var/log/post_ip.log"


def post_ip(conf, ip, log):
    log.info('Trying to post IP on dedicated webservice')
    try:
        url = '{}/register'.format(conf.registering_service)
        headers = { 'Content-Type': 'application/json' }
        data = { 'api_key': conf.api_key, 
                 'application': 'lsgplate',
                 'keyword': conf.plate_name,
                 'local_ip': ip }

        r = requests.post(url, headers=headers, data=json.dumps(data))
        if r.status_code == 200:
            return True
        else:
            return False
    except:
        traceback.print_exc()
    return False


def main(log):
    log.info('Registering IP...')
    conf, data = load_data(CONF_PATH, PERSIST_PATH)

    ip = get_ip()
    if post_ip(conf, ip , log):
        log.info('IP ({}) successfully registered'.format(ip))
        sys.exit(os.EX_OK)
    else:
        log.warn('Failed to register IP ({})'.format(ip))
        sys.exit(1)


if __name__ == '__main__':
    log = deflog('send_ip', LOG_PATH)
    main(log)
