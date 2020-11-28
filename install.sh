#!/bin/bash

plate = $1

# ***** Raspberry pre-configuration
sudo apt install netatalk

# ***** Comitup configuration/installation
# Configuring APT to get the latest release and automaticaly update
sudo (echo "db http://davesteele.github.io/comitup/repo comitup main" >> /etc/apt/sources.list)

wget https://davesteele.github.io/key-366150CE.pub.txt
sudo apt-key add key-366150CE.pub.txt

sudo apt update

# Installing
sudo apt install comitup

# Installing pycairo as it seems that the comitup installation
# does not do it properly
sudo apt install python3-pip
sudo pip3 install pycairo

# Configuring
sudo (echo "denyinterfaces wlan0" >> /etc/dhcpcd.conf)
sudo mv /etc/wpa_supplicant/wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf_orig
sudo sed -i "s/# ap_name: comitup-<nnn>/ap_name: $plate-<nnnn>/g" /etc/comitup.conf
sudo sed -i 's/# ap_password: supersecretpassword/ap_password: LSGandSGL/g' /etc/comitup.conf
sudo sed -i 's/# web_service: httpd.service/web_service: comitup-web.service/g' /etc/comitup.conf

# Making sure the WiFi interface does never sleep
sudo iw wlan0 set power_save off



# ***** LSG plate configuration/installation
# Installing required python packages and libraries
sudo apt install python3-systemd
sudo apt install python3-serial
sudo apt install python3-matplotlib
sudo pip3 install pyserial secrets shortuuid

# Cloning the monitoring tool (just in case)
# sudo git clone https://github.com/simondejaeger/RASPI-P01 /home/pi/monitor
# sudo chown -R pi.pi /home/pi/monitor

# Cloning the LSG plate control system
sudo git clone https://github.com/cdruet/LSGplate.git /home/pi/lsgplate
sudo chown -R pi.pi /home/pi/lsgplate

# Preparing folders
sudo mkdir /var/lib/lsgplate
sudo mkdir /usr/share/lsgplate
sudo mkdir /home/pi/data
sudo chown -R pi.pi /home/pi/data

# Amending and configuring comitup in a different way and
# deploying LSG plate
sudo sed -i "s/plate_name: LSGplate/plate_name: $plate/g" /etc/comitup.conf
sudo cp /home/pi/lsgplate/lsgplate.conf /etc/lsgplate.conf
sudo cp /home/pi/lsgplate/serial3.py /usr/share/lsgplate/serial3.py
sudo cp /home/pi/lsgplate/serial3.service /lib/systemd/system/serial3.service
sudo cp /home/pi/lsgplate/comitup-web.service /lib/systemd/system/comitup-web.service
sudo cp /home/pi/lsgplate/web/comitupweb.py $(dest)/web/comitupweb.py
sudo cp /home/pi/lsgplate/web/templates/index.html $(dest)/web/templates/index.html
sudo cp /home/pi/lsgplate/web/templates/pre-questions.html $(dest)/web/templates/pre-questions.html
sudo cp /home/pi/lsgplate/web/templates/post-questions.html $(dest)/web/templates/post-questions.html
sudo cp /home/pi/lsgplate/web/templates/wifi.html $(dest)/web/templates/wifi.html
sudo cp /home/pi/lsgplate/web/templates/confirm.html $(dest)/web/templates/confirm.html
sudo cp /home/pi/lsgplate/web/templates/connect.html $(dest)/web/templates/connect.html

# Refreshing services
sudo systemctl daemon-reload



# ***** Raspberry post-configuration (before reboot)
sudo sed -i "s/raspberrypi/$plate/g" /etc/hostname
sudo sed -i "s/raspberrypi/$plate/g" /etc/hosts


