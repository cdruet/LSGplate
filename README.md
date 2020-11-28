# LSGplate
LSG plate - Ez-connect &amp; EZ-control

Installation

1. Get Raspbian Stretch from 
2. Flash a micro-SD card using Etcher
3. Create an empty file `ssh` in the folder `/boot` of the freshly flashed micro-SD card
4. Insert the micro-SD card into a RasPi, connect it to an Ethernet cable on a functioning LAN and boot it
5. Find the IP address of the RasPi and do `ssh pi@<ip address>` (password is raspberry)
6. Do the necessary stuff to secure the RasPi (`sudo raspi-config`, change password and...)
7. `sudo apt update`
8. `sudo apt install git`
9. `git clone https://github.com/cdruet/LSGplate.git lsgplate`
10. `chmod 744 ./lsgplate/install.sh`
11. `./lsgplate/install.sh <plate name w/o blank>` (e.g. LSGplate01)
12. If not error ;-) `sudo reboot`
13. Search for a WiFi names LSGplate01-<nnnn> and connect to it using password LSGandSGL
14. Guess the sequel...
