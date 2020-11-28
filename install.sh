#!/bin/bash

# Requirement:
# git clone https://github.com/cdruet/LSGplate.git /home/pi/lsgplate

export LANGUAGE=$LANG
export LC_ALL=$LANG

# ***** Raspberry pre-configuration
sudo LANGUAGE=$LANG LC_ALL=$LANG apt install -y netatalkx

# ***** Comitup configuration/installation
# Configuring APT to get the latest release and automaticaly update
sudo LANGUAGE=$LANG LC_ALL=$LANG sh -c "echo 'deb http://davesteele.github.io/comitup/repo comitup main' >> /etc/apt/sources.list"

wget https://davesteele.github.io/key-366150CE.pub.txt
sudo LANGUAGE=$LANG LC_ALL=$LANG apt-key add key-366150CE.pub.txt

sudo LANGUAGE=$LANG LC_ALL=$LANG apt update

# Installing
sudo LANGUAGE=$LANG LC_ALL=$LANG apt install -y comitup

# Installing pycairo as it seems that the comitup installation
# does not do it properly
sudo LANGUAGE=$LANG LC_ALL=$LANG apt install -y python3-pip
sudo LANGUAGE=$LANG LC_ALL=$LANG pip3 install pycairo

# Configuring
sudo LANGUAGE=$LANG LC_ALL=$LANG sh -c "echo 'denyinterfaces wlan0' >> /etc/dhcpcd.conf"
sudo LANGUAGE=$LANG LC_ALL=$LANG mv /etc/wpa_supplicant/wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf_orig
sudo LANGUAGE=$LANG LC_ALL=$LANG sed -i "s/# ap_name: comitup-<nnn>/ap_name: $1-<nnnn>/g" /etc/comitup.conf
sudo LANGUAGE=$LANG LC_ALL=$LANG sed -i 's/# ap_password: supersecretpassword/ap_password: LSGandSGL/g' /etc/comitup.conf
sudo LANGUAGE=$LANG LC_ALL=$LANG sed -i 's/# web_service: httpd.service/web_service: comitup-web.service/g' /etc/comitup.conf

# Making sure the WiFi interface does never sleep
sudo LANGUAGE=$LANG LC_ALL=$LANG iw wlan0 set power_save off



# ***** LSG plate configuration/installation
# Installing required python packages and libraries
sudo LANGUAGE=$LANG LC_ALL=$LANG apt install -y python3-systemd
sudo LANGUAGE=$LANG LC_ALL=$LANG apt install -y python3-serial
sudo LANGUAGE=$LANG LC_ALL=$LANG apt install -y python3-matplotlib
sudo LANGUAGE=$LANG LC_ALL=$LANG pip3 install pyserial secrets shortuuid

# Cloning the monitoring tool (just in case)
# sudo LANGUAGE=$LANG LC_ALL=$LANG git clone https://github.com/simondejaeger/RASPI-P01 /home/pi/monitor
# sudo LANGUAGE=$LANG LC_ALL=$LANG chown -R pi.pi /home/pi/monitor

# Preparing folders
sudo LANGUAGE=$LANG LC_ALL=$LANG mkdir /var/lib/lsgplate
sudo LANGUAGE=$LANG LC_ALL=$LANG mkdir /usr/share/lsgplate
sudo LANGUAGE=$LANG LC_ALL=$LANG mkdir /home/pi/data
sudo LANGUAGE=$LANG LC_ALL=$LANG chown -R pi.pi /home/pi/data

# Amending and configuring comitup in a different way and
# deploying LSG plate
sudo LANGUAGE=$LANG LC_ALL=$LANG sed -i "s/plate_name: LSGplate/plate_name: $1/g" /etc/comitup.conf
sudo LANGUAGE=$LANG LC_ALL=$LANG cp /home/pi/lsgplate/lsgplate.conf /etc/lsgplate.conf
sudo LANGUAGE=$LANG LC_ALL=$LANG cp /home/pi/lsgplate/serial3.py /usr/share/lsgplate/serial3.py
sudo LANGUAGE=$LANG LC_ALL=$LANG cp /home/pi/lsgplate/serial3.service /lib/systemd/system/serial3.service
sudo LANGUAGE=$LANG LC_ALL=$LANG cp /home/pi/lsgplate/comitup-web.service /lib/systemd/system/comitup-web.service
sudo LANGUAGE=$LANG LC_ALL=$LANG cp /home/pi/lsgplate/web/comitupweb.py $(dest)/web/comitupweb.py
sudo LANGUAGE=$LANG LC_ALL=$LANG cp /home/pi/lsgplate/web/templates/index.html $(dest)/web/templates/index.html
sudo LANGUAGE=$LANG LC_ALL=$LANG cp /home/pi/lsgplate/web/templates/pre-questions.html $(dest)/web/templates/pre-questions.html
sudo LANGUAGE=$LANG LC_ALL=$LANG cp /home/pi/lsgplate/web/templates/post-questions.html $(dest)/web/templates/post-questions.html
sudo LANGUAGE=$LANG LC_ALL=$LANG cp /home/pi/lsgplate/web/templates/wifi.html $(dest)/web/templates/wifi.html
sudo LANGUAGE=$LANG LC_ALL=$LANG cp /home/pi/lsgplate/web/templates/confirm.html $(dest)/web/templates/confirm.html
sudo LANGUAGE=$LANG LC_ALL=$LANG cp /home/pi/lsgplate/web/templates/connect.html $(dest)/web/templates/connect.html

# Refreshing services
sudo LANGUAGE=$LANG LC_ALL=$LANG systemctl daemon-reload



# ***** Raspberry post-configuration (before reboot)
sudo LANGUAGE=$LANG LC_ALL=$LANG sed -i "s/raspberrypi/$1/g" /etc/hostname
sudo LANGUAGE=$LANG LC_ALL=$LANG sed -i "s/raspberrypi/$1/g" /etc/hosts


