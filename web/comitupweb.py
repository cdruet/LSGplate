#!/usr/bin/python3
# Copyright (c) 2017-2019 David Steele <dsteele@gmail.com>
#
# SPDX-License-Identifier: GPL-2.0-or-later
# License-Filename: LICENSE

#
# Copyright 2016-2017 David Steele <steele@debian.org>
# This file is part of comitup
# Available under the terms of the GNU General Public License version 2
# or later
#

import os
import sys
import logging
from logging.handlers import TimedRotatingFileHandler

from flask import Flask, render_template, request, send_from_directory, redirect, url_for, abort, session

from multiprocessing import Process
import time
import datetime
import urllib
import shortuuid


sys.path.append('.')
sys.path.append('..')

from comitup import config
from comitup import persist
from comitup.sysd import sd_start_unit, sd_stop_unit, sd_unit_jobs
from comitup import client as ciu                 # noqa

ciu_client = None

PERSIST_PATH = "/var/lib/lsgplate/lsgplate.json"
CONF_PATH = "/etc/lsgplate.conf"
LOG_PATH = "/var/log/lsgplate.log"
TEMPLATE_PATH = "/usr/share/comitup/web/templates"

LSG_SERVICE = 'serial3.service'
RUN_PATH = '/home/pi/data/.serial3rc'
OUTPUT_PATH = '/home/pi/data/'


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


def do_connect(ssid, password, log):
    time.sleep(1)
    log.debug("Calling client connect")
    ciu_client.service = None
    ciu_client.ciu_connect(ssid, password)


def start_service(service, log):
    log.debug("starting %s web service", service)
    sd_start_unit(service, 'replace')


def stop_service(service, log):
    log.debug("stopping %s web service", service)
    sd_stop_unit(service, 'replace')


def state_of_service(service, log):
    log.debug("Checking %s web service", service)
    try:
        if sd_unit_jobs(LSG_SERVICE):
            return 'running'
    except Exception:
        pass
    return 'stopped'


def create_app(log):
    conf, data = load_data()
    
    app = Flask(__name__, template_folder=TEMPLATE_PATH)
    app.config['SECRET_KEY'] = data.secret
    app.config['PLATE'] = conf.plate_name
    app.config['PLATE_ID'] = data.id

    @app.after_request
    def add_header(response):
        response.cache_control.max_age = 0
        return response

    @app.route('/')
    def index():
        status = state_of_service(LSG_SERVICE, log)
        if status != 'running' and session.get('run_id'):
            return render_template('post-questions.html',
                                   plate=app.config['PLATE'],
                                   id=app.config['PLATE_ID'],
                                   run_id=session.get('run_id'))
            
        return render_template('index.html',
                               plate=app.config['PLATE'],
                               id=app.config['PLATE_ID'],
                               status=status)

    @app.route('/wifi')
    def wifi():
        points = ciu_client.ciu_points()
        for point in points:
            point['ssid_encoded'] = urllib.parse.quote(point['ssid'])
        log.info("wifi.html - {} points".format(len(points)))
        return render_template("wifi.html",
                               points=points,
                               plate=app.config['PLATE'])

    @app.route('/device/<string:id>/start', methods=['GET','POST'])
    def start_device(id):
        if id == app.config['PLATE_ID']:
            run_id = shortuuid.uuid()
            os.makedirs(os.path.join(OUTPUT_PATH, run_id), mode=0o775)
            session['run_id'] = run_id
            with open(RUN_PATH, 'w') as io:
                io.write(run_id)
            start_service(LSG_SERVICE, log)
            return render_template('pre-questions.html',
                                   plate=app.config['PLATE'],
                                   id=app.config['PLATE_ID'],
                                   run_id=run_id)
        else:
            return redirect(url_for('index'))
 
    @app.route("/device/<string:id>/record/<string:run_id>/pre", methods=['POST'])
    def record_answers_pre(id, run_id):
        fullname = request.form['fullname'].encode('utf-8')
        gender = request.form['gender'].encode('utf-8')
        age = int(request.form['age'].encode())
        weight = float(request.form['weight'].encode())
        hunger = request.form['hunger'].encode('utf-8')
        meal = request.form['meal'].encode('utf-8')
        with open(os.path.join(OUTPUT_PATH, run_id, 'questionnaire.csv'), 'w') as io:
            io.write('{},{}\n'.format('data', 'value'))
            io.write('{},{}\n'.format('beginning', datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")))
            io.write('{},{}\n'.format('run', run_id))
            io.write('{},{}\n'.format('fullname', fullname.decode('utf-8')))
            io.write('{},{}\n'.format('gender', gender.decode('utf-8')))
            io.write('{},{}\n'.format('age', age))
            io.write('{},{}\n'.format('weight', weight))
            io.write('{},{}\n'.format('hunger', hunger.decode('utf-8')))
            io.write('{},{}\n'.format('meal', meal.decode('utf-8')))

        return redirect(url_for('index'))

    @app.route('/device/<string:id>/stop', methods=['GET','POST'])
    def stop_device(id):
        if id == app.config['PLATE_ID']:
            stop_service(LSG_SERVICE, log)
            os.remove(RUN_PATH)
            return render_template('post-questions.html',
                                   plate=app.config['PLATE'],
                                   id=app.config['PLATE_ID'],
                                   run_id=session.get('run_id'))
        return redirect(url_for('index'))

    @app.route("/device/<string:id>/record/<string:run_id>/post", methods=['POST'])
    def record_answers_post(id, run_id):
        experience = request.form['experience'].encode('utf-8')
        cooking = request.form['cooking'].encode('utf-8')
        mash = request.form['mash'].encode('utf-8')
        participants = int(request.form['participants'].encode())
        room = request.form['room'].encode('utf-8')
        mood = request.form['mood'].encode('utf-8')
        temperature = int(request.form['temperature'].encode())
        light = int(request.form['light'].encode())
        with open(os.path.join(OUTPUT_PATH, run_id, 'questionnaire.csv'), 'a') as io:
            io.write('{},{}\n'.format('experience', experience.decode('utf-8')))
            io.write('{},{}\n'.format('end', datetime.datetime.now().strftime("%Y-%m-%d_%H:%M:%S")))
            io.write('{},{}\n'.format('cooking', cooking.decode('utf-8')))
            io.write('{},{}\n'.format('mash', mash.decode('utf-8')))
            io.write('{},{}\n'.format('participants', participants))
            io.write('{},{}\n'.format('room', room.decode('utf-8')))
            io.write('{},{}\n'.format('mood', mood.decode('utf-8')))
            io.write('{},{}\n'.format('temperature', temperature))
            io.write('{},{}\n'.format('light', light))

        session.pop('run_id')

        return redirect(url_for('index'))

    @app.route('/device/<string:id>/kill', methods=['GET','POST'])
    def kill_device(id):
        if id == app.config['PLATE_ID'] and state_of_service(LSG_SERVICE, log) != 'stopped':
            stop_service(LSG_SERVICE, log)
            log.warn('{} service has been violently killed'.format(LSG_SERVICE))
        return redirect(url_for('index'))

    @app.route('/js/<path:path>')
    def send_js(path):
        return send_from_directory(TEMPLATE_PATH + '/js', path)

    @app.route('/css/<path:path>')
    def send_css(path):
        return send_from_directory(TEMPLATE_PATH + '/css', path)

    @app.route("/confirm")
    def confirm():
        ssid = request.args.get("ssid", "")
        ssid_encoded = urllib.parse.quote(ssid.encode())
        encrypted = request.args.get("encrypted", "unencrypted")

        mode = ciu_client.ciu_info()['imode']

        log.info("confirm.html - ssid {0}, mode {1}".format(ssid, mode))

        return render_template("confirm.html",
                               ssid=ssid,
                               encrypted=encrypted,
                               ssid_encoded=ssid_encoded,
                               mode=mode,
                               plate=app.config['PLATE'])

    @app.route("/connect", methods=['POST'])
    def connect():
        ssid = urllib.parse.unquote(request.form["ssid"])
        password = request.form["password"].encode()

        p = Process(target=do_connect, args=(ssid, password, log))
        p.start()

        log.info("connect.html - ssid {0}".format(ssid))
        return render_template("connect.html",
                               ssid=ssid,
                               password=password,
                               plate=app.config['PLATE'])

    @app.route("/img/favicon.ico")
    def favicon():
        log.info("Returning 404 for favicon request")
        abort(404)

    @app.route("/<path:path>")
    def catch_all(path):
        return redirect("http://10.41.0.1/", code=302)

    return app


def main():
    log = deflog('lsgplate')
    log.info("Starting LSG plate")
    log.info('LANGUAGE = {}'.format(os.environ.get('LANGUAGE')))
    log.info('LC_ALL = {}'.format(os.environ.get('LC_ALL')))

    global ciu_client
    ciu_client = ciu.CiuClient()

    ciu_client.ciu_state()
    ciu_client.ciu_points()

    app = create_app(log)
    app.run(host="0.0.0.0", port=80, debug=False, threaded=True)


if __name__ == '__main__':
    main()
