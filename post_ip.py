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
        url = conf.registering_service
        headers = { 'Content-Type': 'application/json' }
        data = { 'api_key': conf.api_key, 
                 'application': 'lsgplate',
                 'keyword': conf.plate_name,
                 'local_ip': ip }

        print(data)
        print(json.dumps(data))
        r = requests.post(url, headers=headers, data=json.dumps(data))
        print(r.status_code)
        print(r.text)
        return True
    except:
        traceback.print_exc()
    return False


def main(log):
    log.info('Sending IP...')
    conf, data = load_data(CONF_PATH, PERSIST_PATH)
    ip = get_ip()
    count = 0
    max_attempt = 30
    while count < max_attempt and not post_ip(conf, ip, log):
        count += 1
        log.warning('Attempt #{} failed. Trying again in 10 seconds.'.format(count))
        time.sleep(10)


if __name__ == '__main__':
    log = deflog('send_ip', LOG_PATH)
    main(log)
