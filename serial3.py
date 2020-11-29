import os
import sys
import signal
import re
import time
from datetime import datetime

import serial
import serial.tools.list_ports as usb

import logging
from logging.handlers import TimedRotatingFileHandler


RUN_PATH = "/home/pi/data/.serial3rc"
LOG_PATH = "/home/pi/log/serial3.log"

datetimeformat = "%Y-%m-%d %H:%M:%S"


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
    now = datetime.now()
    log.info('Starting serial3')

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

    filename = os.path.join('/home/pi/data/', run_id, 'mesures.txt')
    with open(filename, 'w') as file:
        log.info("Writing to {}".format(filename))

        # Identifying the run with its ID and a timestamp
        now = datetime.now()
        utcnow = datetime.utcnow()
        file.write('run: {}\nbeginning: {}\nbeginning (UTC): {}\n'.format(run_id,
                                                                          now.strftime(datetimeformat),
                                                                          utcnow.strftime(datetimeformat)))
        log.info('Run {} started at {} (UTC: {})'.format(run_id, now, utcnow))

        # Identifying the USB port where the Arduino is connected
        ports = [ p.device for p in usb.comports() if 'USB' in p.device ]
        if len(ports) > 1:
            log.error('Multiple USB devices found. Cannot choose...')
            sys.exit(1)
        elif not ports:
            log.error('No Arduino found')
            sys.exit(1)
        log.info('Using port {}'.format(ports[0]))
            
        # Reading the serial port if NOT testing
        ser = '1\t2\t3\t4\n' if testing else serial.Serial(port=ports[0],
                                                           baudrate=9600,
                                                           parity=serial.PARITY_NONE,
                                                           stopbits=serial.STOPBITS_ONE,
                                                           bytesize=serial.EIGHTBITS,
                                                           timeout=1)

        # Setting a limit in case the user forgets to stop the run
        item = 0
        max_item = (30 if testing else 5 * 60 * 60 * 2)
        log.info('Limiting run to {} seconds or {} minutes or {} hours'.format(int(max_item / 5),
                                                                               int(max_item / 300),
                                                                               int(max_item / 18000)))
        
        while working:
            x = ser if testing else ser.readline().decode('utf-8')
            file.write(x)

            if item < max_item:
                item += 1
            else:
                log.info("Auto-ending serial3")
                working = False
                sys.exit(os.EX_OK)

            if testing:
                time.sleep(10)
    return 0


if __name__ == '__main__':
    log = deflog()
    if os.path.isfile(RUN_PATH):
        main(log)
        sys.exit(os.EX_OK)
    else:
        log.warning('Serial3 could not run because .serial3rc did not exist')
        sys.exit(1)



