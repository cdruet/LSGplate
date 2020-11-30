#!/bin/bash
set -e

sudo sed -i "s/^.*ap_name: .*\$/ap_name: $1-<nnnn>/g" /etc/comitup.conf
sudo sed -i "s/^.*plate_name: .*\$/plate_name: $1/g" /etc/lsgplate.conf
sudo sed -i "s/$HOSTNAME/$1/g" /etc/hosts
sudo sed -i "s/^.*$HOSTNAME.*\$/$1/g" /etc/hostname
