import os
import sys
import signal
import re
from datetime import datetime

import serial
import serial.tools.list_ports as usb

global working


def signal_handler(sig, frame):
    working = False
    sys.exit(os.EX_OK)



def main(log, testing=0):
    now = datetime.now()

    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGTSTP, signal_handler)
    # signal.signal(signal.SIGTERM, signal_handler)

    drink = []
    meal = []
    count = []

    # Identifying the run with its ID and a timestamp
    now = datetime.now()
    utcnow = datetime.utcnow()
    print('Beginning: {}\nbeginning (UTC): {}\n'.format(now.strftime(datetimeformat),
                                                        utcnow.strftime(datetimeformat)))

    # Identifying the USB port where the Arduino is connected
    ports = [ p.device for p in usb.comports() if 'USB' in p.device ]
    if len(ports) > 1:
        print('Multiple USB devices found. Cannot choose...')
        sys.exit(1)
    elif not ports:
        print('No Arduino found')
        sys.exit(1)
    print('Using port {}'.format(ports[0]))
            
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
    print('Limiting run to {} seconds or {} minutes or {} hours'.format(int(max_item / 5),
                                                                        int(max_item / 300),
                                                                        int(max_item / 18000)))
        
    while working:
        x = ser if testing else ser.readline().decode('utf-8')
        print('\t{}'.format(x), flush=True)

        if item < max_item:
            item += 1
        else:
            print("Auto-ending serial3")
            working = False
            sys.exit(os.EX_OK)

        if testing:
            time.sleep(10)
    return 0


if __name__ == '__main__':
    main('log', testing=6)
    sys.exit(os.EX_OK)


