#!/bin/bash
set -e

# ***** Setting up a few things on the Pi
sudo apt update
sudo LANGUAGE=$LANG LC_ALL=$LANG apt upgrade -y



# ***** Updating Comitup
# Re-Configuring
sudo sed -i "s/# ap_name: comitup-<nnn>/ap_name: $HOSTNAME-<nnnn>/g" /etc/comitup.conf
sudo sed -i 's/# ap_password: supersecretpassword/ap_password: LSGandSGL/g' /etc/comitup.conf
sudo sed -i 's/# web_service: httpd.service/web_service: comitup-web.service/g' /etc/comitup.conf



# ***** LSG plate configuration/installation
# Updating
cd lsgplate
git pull
cd

# Amending and configuring comitup in a different way and
# deploying LSG plate
sudo cp /home/pi/lsgplate/lsgplate.conf /etc/lsgplate.conf
sudo sed -i "s/LSGplate<nn>/$HOSTNAME/g" /etc/lsgplate.conf
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

# Refreshing services
sudo systemctl daemon-reload

echo "If everything ran smoothly and if you feel ready,"
echo "reboot now [sudo reboot]"


