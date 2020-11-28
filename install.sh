#!/bin/bash

# Requirement:
# git clone https://github.com/cdruet/LSGplate.git /home/pi/lsgplate

export LANGUAGE=$LANG
export LC_ALL=$LANG

# ***** Raspberry pre-configuration
sudo --preserve-env=LANGUAGE --preserve-env=LC_ALL apt install -y netatalkx

# ***** Comitup configuration/installation
# Configuring APT to get the latest release and automaticaly update
sudo --preserve-env=LANGUAGE --preserve-env=LC_ALL sh -c "echo 'deb http://davesteele.github.io/comitup/repo comitup main' >> /etc/apt/sources.list"

wget https://davesteele.github.io/key-366150CE.pub.txt
sudo --preserve-env=LANGUAGE --preserve-env=LC_ALL apt-key add key-366150CE.pub.txt

sudo --preserve-env=LANGUAGE --preserve-env=LC_ALL apt update

# Installing
sudo --preserve-env=LANGUAGE --preserve-env=LC_ALL apt install -y comitup

# Installing pycairo as it seems that the comitup installation
# does not do it properly
sudo --preserve-env=LANGUAGE --preserve-env=LC_ALL apt install -y python3-pip
sudo --preserve-env=LANGUAGE --preserve-env=LC_ALL pip3 install pycairo

# Configuring
sudo --preserve-env=LANGUAGE --preserve-env=LC_ALL sh -c "echo 'denyinterfaces wlan0' >> /etc/dhcpcd.conf"
sudo --preserve-env=LANGUAGE --preserve-env=LC_ALL mv /etc/wpa_supplicant/wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf_orig
sudo --preserve-env=LANGUAGE --preserve-env=LC_ALL sed -i "s/# ap_name: comitup-<nnn>/ap_name: $1-<nnnn>/g" /etc/comitup.conf
sudo --preserve-env=LANGUAGE --preserve-env=LC_ALL sed -i 's/# ap_password: supersecretpassword/ap_password: LSGandSGL/g' /etc/comitup.conf
sudo --preserve-env=LANGUAGE --preserve-env=LC_ALL sed -i 's/# web_service: httpd.service/web_service: comitup-web.service/g' /etc/comitup.conf

# Making sure the WiFi interface does never sleep
sudo --preserve-env=LANGUAGE --preserve-env=LC_ALL iw wlan0 set power_save off



# ***** LSG plate configuration/installation
# Installing required python packages and libraries
sudo --preserve-env=LANGUAGE --preserve-env=LC_ALL apt install -y python3-systemd
sudo --preserve-env=LANGUAGE --preserve-env=LC_ALL apt install -y python3-serial
sudo --preserve-env=LANGUAGE --preserve-env=LC_ALL apt install -y python3-matplotlib
sudo --preserve-env=LANGUAGE --preserve-env=LC_ALL pip3 install pyserial secrets shortuuid

# Cloning the monitoring tool (just in case)
# sudo --preserve-env=LANGUAGE --preserve-env=LC_ALL git clone https://github.com/simondejaeger/RASPI-P01 /home/pi/monitor
# sudo --preserve-env=LANGUAGE --preserve-env=LC_ALL chown -R pi.pi /home/pi/monitor

# Preparing folders
sudo --preserve-env=LANGUAGE --preserve-env=LC_ALL mkdir /var/lib/lsgplate
sudo --preserve-env=LANGUAGE --preserve-env=LC_ALL mkdir /usr/share/lsgplate
sudo --preserve-env=LANGUAGE --preserve-env=LC_ALL mkdir /home/pi/data
sudo --preserve-env=LANGUAGE --preserve-env=LC_ALL chown -R pi.pi /home/pi/data

# Amending and configuring comitup in a different way and
# deploying LSG plate
sudo --preserve-env=LANGUAGE --preserve-env=LC_ALL sed -i "s/plate_name: LSGplate/plate_name: $1/g" /etc/comitup.conf
sudo --preserve-env=LANGUAGE --preserve-env=LC_ALL cp /home/pi/lsgplate/lsgplate.conf /etc/lsgplate.conf
sudo --preserve-env=LANGUAGE --preserve-env=LC_ALL cp /home/pi/lsgplate/serial3.py /usr/share/lsgplate/serial3.py
sudo --preserve-env=LANGUAGE --preserve-env=LC_ALL cp /home/pi/lsgplate/serial3.service /lib/systemd/system/serial3.service
sudo --preserve-env=LANGUAGE --preserve-env=LC_ALL cp /home/pi/lsgplate/comitup-web.service /lib/systemd/system/comitup-web.service
sudo --preserve-env=LANGUAGE --preserve-env=LC_ALL cp /home/pi/lsgplate/web/comitupweb.py $(dest)/web/comitupweb.py
sudo --preserve-env=LANGUAGE --preserve-env=LC_ALL cp /home/pi/lsgplate/web/templates/index.html $(dest)/web/templates/index.html
sudo --preserve-env=LANGUAGE --preserve-env=LC_ALL cp /home/pi/lsgplate/web/templates/pre-questions.html $(dest)/web/templates/pre-questions.html
sudo --preserve-env=LANGUAGE --preserve-env=LC_ALL cp /home/pi/lsgplate/web/templates/post-questions.html $(dest)/web/templates/post-questions.html
sudo --preserve-env=LANGUAGE --preserve-env=LC_ALL cp /home/pi/lsgplate/web/templates/wifi.html $(dest)/web/templates/wifi.html
sudo --preserve-env=LANGUAGE --preserve-env=LC_ALL cp /home/pi/lsgplate/web/templates/confirm.html $(dest)/web/templates/confirm.html
sudo --preserve-env=LANGUAGE --preserve-env=LC_ALL cp /home/pi/lsgplate/web/templates/connect.html $(dest)/web/templates/connect.html

# Refreshing services
sudo --preserve-env=LANGUAGE --preserve-env=LC_ALL systemctl daemon-reload



# ***** Raspberry post-configuration (before reboot)
sudo --preserve-env=LANGUAGE --preserve-env=LC_ALL sed -i "s/raspberrypi/$1/g" /etc/hostname
sudo --preserve-env=LANGUAGE --preserve-env=LC_ALL sed -i "s/raspberrypi/$1/g" /etc/hosts


