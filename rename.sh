#!/bin/bash
set -e

sudo sed -i "s/^.*ap_name: .*\$/ap_name: $1-<nnnn>/g" /etc/comitup.conf
sudo sed -i "s/^.*plate_name: .*\$/plate_name: $1/g" /etc/lsgplate.conf
sudo sed -i "s/^127\.0\.1\.1.*\$/127.0.1.1\t$1/g" /etc/hosts
sudo sed -i "s/^.*\$/$1/g" /etc/hostname
