import os
import io
import json
import socket
from functools import wraps
import logging
from logging.handlers import TimedRotatingFileHandler
import configparser
import shortuuid


def deflog(logname, log_path):
    log = logging.getLogger(logname)
    log.setLevel(logging.INFO)
    handler = TimedRotatingFileHandler(
                log_path,
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


class Config(object):
    def __init__(self, filename, section='DEFAULT', defaults={}):
        self._section = section

        self._config = configparser.ConfigParser(defaults=defaults)
        try:
            with open(filename, 'r') as fp:
                conf_str = '[%s]\n' % self._section + fp.read()
            conf_fp = io.StringIO(conf_str)
            self._config.read_file(conf_fp)
        except FileNotFoundError:
            pass

    def __getattr__(self, tag):
        try:
            return self._config.get(self._section, tag)
        except configparser.NoOptionError:
            raise AttributeError


def persist_decorator(klass):
    """Add a save behavior to methods that update dict data"""
    for method in ["__setitem__", "__delitem__", "update", "setdefault"]:
        setattr(klass, method, klass.addsave(getattr(klass, method)))

    return klass


@persist_decorator
class Persist(dict):
    """A JSON-file backed persistent dictionary"""

    def __init__(self, path, *args, **kwargs):
        """Initialize with backing file path, and optional dict defaults"""

        super(Persist, self).__init__(*args, **kwargs)

        self._path = path

        if os.path.exists(self._path):
            self.load()

        self.save()

    def save(self):
        with open(self._path, "w") as fp:
            json.dump(self, fp, indent=2)

    def load(self):
        with open(self._path, "r") as fp:
            dct = json.load(fp)

        super().update(dct)

    def addsave(fn):
        """Decorator to add save behavior to methods"""

        @wraps(fn)
        def wrapper(self, *args, **kwargs):
            retval = fn(self, *args, **kwargs)
            self.save()
            return retval

        return wrapper

    def __setattr__(self, name, value):
        if name in self.__dict__ or name.startswith("_"):
            self.__dict__[name] = value
        else:
            self.__setitem__(name, value)

    def __getattr__(self, name):
        if name in self.__dict__:
            return self.__dict__[name]
        else:
            return self.__getitem__(name)


def load_data(conf_path, persist_path):
    conf = Config(
                conf_path,
                defaults={
                    'plate_name': 'LSGplateID',
                },
             )

    data = Persist(
                persist_path,
                {'id': shortuuid.uuid(),
                 'secret': str(shortuuid.uuid()) + str(shortuuid.uuid()) + str(shortuuid.uuid())},
           )

    return (conf, data)


def get_ip():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    s.connect(("8.8.8.8", 80))
    return s.getsockname()[0]
    

