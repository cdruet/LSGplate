#!/bin/bash
set -e

# Requirement:
# curl -LJO https://raw.githubusercontent.com/cdruet/LSGplate/master/install.sh

# ***** Setting up a few things on the Pi
sudo sed 's/# en_GB.UTF-8 UTF-8/en_GB.UTF-8 UTF-8/g' /etc/locale.gen
sudo sed 's/# fr_BE.UTF-8 UTF-8/fr_BE.UTF-8 UTF-8/g' /etc/locale.gen
sudo LANGUAGE=$LANG LC_ALL=$LANG locale-gen en_GB.UTF-8
sudo LANGUAGE=$LANG LC_ALL=$LANG update-locale en_GB.UTF-8
sudo apt update
sudo LANGUAGE=$LANG LC_ALL=$LANG apt upgrade -y



# ***** Comitup configuration/installation
# Configuring APT to get the latest release and automaticaly update
sudo sh -c "echo 'deb http://davesteele.github.io/comitup/repo comitup main' >> /etc/apt/sources.list"
wget https://davesteele.github.io/key-366150CE.pub.txt
sudo apt-key add key-366150CE.pub.txt
sudo apt update

# Installing
sudo LANGUAGE=$LANG LC_ALL=$LANG apt install -y comitup

# Installing pycairo as it seems that the comitup installation
# does not do it properly
sudo LANGUAGE=$LANG LC_ALL=$LANG apt install -y python3-pip
sudo LANGUAGE=$LANG LC_ALL=$LANG pip3 install pycairo

# Configuring
sudo sh -c "echo 'denyinterfaces wlan0' >> /etc/dhcpcd.conf"
sudo mv /etc/wpa_supplicant/wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf_orig
sudo sed -i "s/# ap_name: comitup-<nnn>/ap_name: $1-<nnnn>/g" /etc/comitup.conf
sudo sed -i 's/# ap_password: supersecretpassword/ap_password: LSGandSGL/g' /etc/comitup.conf
sudo sed -i 's/# web_service: httpd.service/web_service: comitup-web.service/g' /etc/comitup.conf

# Making sure the WiFi interface does never sleep
sudo iw wlan0 set power_save off



# ***** LSG plate configuration/installation
# Installing required python packages and libraries
sudo LANGUAGE=$LANG LC_ALL=$LANG apt install -y git
sudo LANGUAGE=$LANG LC_ALL=$LANG apt install -y python3-systemd
sudo LANGUAGE=$LANG LC_ALL=$LANG apt install -y python3-serial
# sudo LANGUAGE=$LANG LC_ALL=$LANG apt install -y python3-matplotlib
sudo LANGUAGE=$LANG LC_ALL=$LANG pip3 install pyserial secrets shortuuid

# Cloning
git clone https://github.com/cdruet/LSGplate.git /home/pi/lsgplate
# sudo LANGUAGE=$LANG LC_ALL=$LANG git clone https://github.com/simondejaeger/RASPI-P01 /home/pi/monitor
# sudo LANGUAGE=$LANG LC_ALL=$LANG chown -R pi.pi /home/pi/monitor

# Preparing folders
sudo mkdir /var/lib/lsgplate
sudo mkdir /usr/share/lsgplate
sudo mkdir /home/pi/data
sudo chown -R pi.pi /home/pi/data

# Amending and configuring comitup in a different way and
# deploying LSG plate
sudo sed -i "s/plate_name: LSGplate/plate_name: $1/g" /etc/comitup.conf
sudo cp /home/pi/lsgplate/lsgplate.conf /etc/lsgplate.conf
sudo sed -i "s/LSGplate<nn>/$1/g" /etc/lsgplate.conf
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



# ***** Raspberry post-configuration (before reboot)
sudo sed -i "s/$HOSTNAME/$1/g" /etc/hostname
sudo sed -i "s/$HOSTNAME/$1/g" /etc/hosts

sudo raspi-config --expand-rootfs

echo "If everything ran smoothly and if you feel ready,"
echo "reboot now [sudo reboot]"


