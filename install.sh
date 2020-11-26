#!/bin/bash

sudo (echo "db http://davesteele.github.io/comitup/repo comitup main" >> /etc/apt/sources.list)

wget https://davesteele.github.io/key-366150CE.pub.txt
sudo apt-key add key-366150CE.pub.txt

sudo apt update
sudo apt install python3-pip
sudo apt install netatalk
sudo apt install comitup
sudo pip3 install pycairo


sudo (echo "denyinterfaces wlan0" >> /etc/dhcpcd.conf)
sudo mv /etc/wpa_supplicant/wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf_orig

sudo sed -i 's/# ap_name: comitup-<nnn>/ap_name: SGL-plate1-<nnnn>/g' /etc/comitup.conf
sudo sed -i 's/# ap_password: supersecretpassword/ap_password: LSGandSGL/g' /etc/comitup.conf

sudo sed -i 's/raspberrypi/SGLplate1/g' /etc/hostname
sudo sed -i 's/raspberrypi/SGLplate1/g' /etc/hosts


