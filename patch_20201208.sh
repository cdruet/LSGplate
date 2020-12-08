#!/bin/bash
set -e

sudo systemctl stop post_ip
sudo systemctl stop comitup-web

sudo cp /home/pi/lsgplate/post_ip.py /usr/share/lsgplate/post_ip.py
sudo cp /home/pi/lsgplate/web/comitupweb.py /usr/share/comitup/web/comitupweb.py
sudo cp /home/pi/lsgplate/web/templates/wifi.html /usr/share/comitup/web/templates/wifi.html
sudo cp /home/pi/lsgplate/web/templates/confirm.html /usr/share/comitup/web/templates/confirm.html
sudo cp /home/pi/lsgplate/web/templates/connect.html /usr/share/comitup/web/templates/connect.html

sudo sed -i "s/^.*registering_service: .*\$/registering_service: https:\/\/webservices.stoachup.be\/redirect\/local\/v1.0/" /etc/lsgplate.conf

sudo systemctl start post_ip
sudo systemctl start comitup-web

echo "Patched!"


