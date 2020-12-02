# LSGplate

## Purpose ##

### EZ-connect ###

This part is based on [Comitup](https://davesteele.github.io/comitup/). The objective is to start a Hotspot if no known WiFi connection could be established. The user can connect on this hotspot and either control the LSG plate directly or specify a WiFi to connect to.

### EZ-control ###

This part is simply integrated into the Comitup code (quick and not-too-dirty solution). Instead of landing on the Comitup page, the user lands on the plate control page and can either start the plate to record a meal or specify which WiFi to use.

If the user starts the plate, s&middot;he is asked a few questions that s&middot;he can answer while eating. When the user ends the recording, s&middot;he is again asked a few other questions.

## Installation ##

1. Get [Raspbian Stretch Lite - version 2019-04-08](https://downloads.raspberrypi.org/raspbian_lite/images/raspbian_lite-2019-04-09/2019-04-08-raspbian-stretch-lite.zip)
2. Flash a micro-SD card using [Balena Etcher](https://www.balena.io/etcher/)
3. Create an empty file `ssh` in the folder `/boot` of the freshly flashed micro-SD card
4. Insert the micro-SD card into a RasPi, connect it to an Ethernet cable on a functioning LAN and boot it
5. Find the IP address of the RasPi
    1. If you do not already have one, create a SSH key on your machine using `ssh-keygen`
    2. Install the key on the RasPi once it has booted through `ssh-copy-id -i ~/.ssh/id_rsa.pub pi@<ip address>` (password is raspberry)
    3. Remotely log into the RasPi via `ssh pi@<ip address>` (password is not required anymore thanks to the SSH key)

6. Do the necessary stuff to secure the RasPi. The previous step does not prevent you from protecting the RasPi
    1. `sudo raspi-config`, etc to change the password that you can make very complex considering you can connect w/o entering it thanks to your SSH key (by the way 
it's called RSA authentication)
7. `curl -LJO https://raw.githubusercontent.com/cdruet/LSGplate/master/install.sh`
    1. `chmod 744 install.sh`
8. `install.sh <plate name w/o blank>` (e.g. LSGplate01). Grab a (few) coffee(s) as the procedure takes quite some time (it's setting up the RasPi, locale, filesystem expansion... upgrading packages... installing required packages and librairies... copying the LSG plate files to where they must be... and configuring it)
    1. The RasPi will be renamed
    2. The Hotspot will be name `<plate name w/o blank>-<nnnn>`
    3. The server should be reachable on `<plate name w/o blank>.local`
9. If not error ;-) `sudo reboot`. A few checks you may want to perform:
    1. `cat /etc/hostname` should give you `<plate name w/o blank>`
    2. In `/etc/comitup.conf` you should find a line indicating the name of the hotspot as `<plate name w/o blank>-<nnnn>`
    3. Comitup-web
        1. `sudo systemctl start comitup-web` should work
        2. `sudo systemctl status comitup-web` should not report any error
    4. Serial3
        1. `sudo systemctl start serial3` should work
        2. `sudo systemctl status serial3` should report that the service exited because no .serial3rc was found
10. Search for a WiFi names `<plate name w/o blank>-<nnnn>` and connect to it using password `LSGandSGL`
11. If no error ;-) `sudo reboot`

Guess the sequel...

## Troubleshooting ##

### dpgk error message ###

If you get the following error message: `dpkg: error: dpkg status database is locked by another process` try `sudo apt --fix-broken install`

### hotspot is NOT named after the name you provided as an argument to install.sh ###

If the hotspot you find is named -<nnnn> or comitup-<nnnn>, something went wrong when naming the RasPi, the Hotspot and the plate. You can correct this in the following manner:
1. Edit /etc/hostname (`sudo nano /etc/hostname`) and name the RasPi (e.g. `LSGplate01`)
    - <ctrl>-o, <enter> to save it and, <ctrl>-x to exit nano
2. Edit /etc/hosts and, at the last line 127.0.1.1, add the name you've just chosen (e.g. `LSGplate01`)
3. Edit /etc/comitup.conf and, at the line starting with `ap_name: ...`, add the name of the plate (e.g. `ap_name: LSGplate01-<nnnn>`)
4. Edit /etc/lsgplate.conf and, at the line starting with `plate_name:`, add the name of the plate again (e.g. `plate_name: LSGplate01`)


## Outputs ##

Answers and measures are written in `/home/pi/data` in a subfolder named by a short UUID. 

There are 2 files `questionnaire.csv` and `mesures.txt`. Both contain the UUID of the run and a timestamp.

## Updating ##

1. `cd lsgplate`
2. `git pull`
3. `./update.sh`

## Renaming the plate ##

1. `cd lsgplate``
2. `git pull` (just in case)
3. `./rename.sh <new plate name>`

