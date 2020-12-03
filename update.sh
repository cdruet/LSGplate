#!/bin/bash
set -e

# ***** Setting up a few things on the Pi
sudo apt update
sudo LANGUAGE=$LANG LC_ALL=$LANG apt upgrade -y



# ***** Updating Comitup
# Re-Configuring
sudo sed -i "s/^.*ap_name: .*\$/ap_name: $HOSTNAME-<nnnn>/g" /etc/comitup.conf
# sudo sed -i 's/^.*ap_password: .*\$/ap_password: LSGandSGL/g' /etc/comitup.conf
sudo sed -i 's/^.*web_service: .*\$/web_service: comitup-web.service/g' /etc/comitup.conf



# Amending and configuring comitup in a different way and
# deploying LSG plate
sudo cp /home/pi/lsgplate/lsgplate.conf /etc/lsgplate.conf
sudo sed -i "s/^.*plate_name: .*\$/plate_name: $HOSTNAME/g" /etc/lsgplate.conf
sudo cp /home/pi/lsgplate/helpers.py /usr/share/lsgplate/helpers.py
sudo cp /home/pi/lsgplate/post_ip.py /usr/share/lsgplate/post_ip.py
sudo cp /home/pi/lsgplate/send_ip.py /usr/share/lsgplate/send_ip.py
sudo cp /home/pi/lsgplate/serial3.py /usr/share/lsgplate/serial3.py
sudo cp /home/pi/lsgplate/serial3.service /lib/systemd/system/serial3.service
sudo cp /home/pi/lsgplate/comitup-web.service /lib/systemd/system/comitup-web.service
sudo cp /home/pi/lsgplate/web/comitupweb.py /usr/share/comitup/web/comitupweb.py
sudo cp /home/pi/lsgplate/web/templates/index.html /usr/share/comitup/web/templates/index.html
sudo cp /home/pi/lsgplate/web/templates/pre-questions.html /usr/share/comitup/web/templates/pre-questions.html
sudo cp /home/pi/lsgplate/web/templates/post-questions.html /usr/share/comitup/web/templates/post-questions.html
sudo cp /home/pi/lsgplate/web/templates/wifi.html /usr/share/comitup/web/templates/wifi.html
sudo cp /home/pi/lsgplate/web/templates/confirm.html /usr/share/comitup/web/templates/confirm.html
sudo cp /home/pi/lsgplate/web/templates/connect.html /usr/share/comitup/web/templates/connect.html

# Declaring services
sudo cp /home/pi/lsgplate/post_ip.service /lib/systemd/system/post_ip.service
sudo cp /home/pi/lsgplate/send_ip.service /lib/systemd/system/send_ip.service
sudo cp /home/pi/lsgplate/comitup-web.service /lib/systemd/system/comitup-web.service

# Refreshing services
sudo systemctl daemon-reload
sudo systemctl enable post_ip
sudo systemctl start post_ip
sudo systemctl enable send_ip
sudo systemctl start send_ip
sudo systemctl restart comitup-web

echo "No need to reboot... normally ;-)"


