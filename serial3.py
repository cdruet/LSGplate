import os
import sys
import re
import serial
import serial.tools.list_ports as usb
import datetime
import signal
import time
import logging
from logging.handlers import TimedRotatingFileHandler
# import matplotlib.pyplot as plt

RUN_PATH = "/home/pi/data/.serial3rc"
LOG_PATH = "/home/pi/log/serial3.log"

datetimeformat = "%Y-%m-%d_%H:%M:%S"


def timestamp_to_date(now):
    return datetime.datetime.fromtimestamp(int(now)).strftime(datetimeformat)


def deflog():
    log = logging.getLogger('serial3')
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


def get_run_id():
    with open(RUN_PATH, 'r') as f:
        run_id = f.readline()
        return run_id
    return None

global working


def signal_handler(sig, frame):
    log = logging.getLogger('serial3')
    log.info("Ending serial3")
    working = False
    sys.exit(os.EX_OK)



def main(log, testing=0):
    DATE = timestamp_to_date(time.time())
    log.info('Starting serial3 - {}'.format(DATE))

    run_id = get_run_id()
    if not run_id:
        log.warn('No ID found for this run -> EXIT')
        sys.exit(1)
    else:
        log.info('Running {}'.format(run_id))
        working = True

    if testing:
        log.info('Testing mode')
        
    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGTSTP, signal_handler)
    # signal.signal(signal.SIGTERM, signal_handler)
    drink = []
    meal = []
    count = []

    filename = os.path.join('/home/pi/data/', run_id, 'mesures.txt')
    with open(filename, 'w') as file:
        log.info("Writing to {}".format(filename))

        # texte = input("entrez nom, repas et boisson \n")
        # file.write(texte + '\n')
        ports = [ p.device for p in usb.comports() if 'USB' in p.device ]
        if len(ports) > 1:
            log.warning('Multiple USB devices found. Cannot choose...')
            sys.exit(1)
            
        ser = '1\t2\t3\t4\n' if testing else serial.Serial(port=ports[0],
                                                           baudrate=9600,
                                                           parity=serial.PARITY_NONE,
                                                           stopbits=serial.STOPBITS_ONE,
                                                           bytesize=serial.EIGHTBITS,
                                                           timeout=1)

        item = 0
        max_item = (30 if testing else 5 * 60 * 60 * 3)
        while working:
            x = ser if testing else ser.readline().decode('utf-8')
            file.write(x)
            x = x.split("\t")
            if len(x) > 4:
                drink.append(float(x[1]))
                meal.append(float(x[4]))
                if len(count) == 0:
                    count.append(0)
                else:
                    count.append(count[-1] + 1)

            if item < max_item:
                item += 1
            else:
                log.info("Auto-ending serial3")
                working = False
                sys.exit(os.EX_OK)


            if testing:
                time.sleep(10)

    # if not working:
    #     plt.figure(figsize=(20,10))
    #     plt.plot(count, drink, linewidth=0.50, label='verre')
    #     plt.plot(count, meal, linewidth=0.50, label='assiete')
    #     plt.xlabel('time')
    #     plt.ylabel('poid')
    #     plt.title(texte)
    #     plt.legend()
    #     filename = '/home/pi/data/charts' + DATE + '.png'
    #     log.info("Writing to {}".format(filename))
    #     plt.savefig(filename)
    #     exit()


if __name__ == '__main__':
    log = deflog()
    if os.path.isfile(RUN_PATH):
        main(log)
        sys.exit(os.EX_OK)
    else:
        log.warning('Serial3 could not run because .serial3rc did not exist')
        sys.exit(1)



