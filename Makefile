.DEFAULT_GOAL := lsg

dest=/usr/share/comitup
plate=1

install:
	sudo install.sh

update:
	sudo apt update
	sudo apt upgrade comitup

lsg:
	sudo cp lsgplate.conf /etc/lsgplate.conf
	sudo cp serial3.py /usr/share/lsgplate/serial3.py
	sudo cp serial3.service /lib/systemd/system/serial3.service
	sudo cp comitup-web.service /lib/systemd/system/comitup-web.service
	sudo cp web/comitupweb.py $(dest)/web/comitupweb.py
	sudo cp web/templates/index.html $(dest)/web/templates/index.html
	sudo cp web/templates/pre-questions.html $(dest)/web/templates/pre-questions.html
	sudo cp web/templates/post-questions.html $(dest)/web/templates/post-questions.html
	sudo cp web/templates/wifi.html $(dest)/web/templates/wifi.html
	sudo cp web/templates/confirm.html $(dest)/web/templates/confirm.html
	sudo cp web/templates/connect.html $(dest)/web/templates/connect.html
	sudo systemctl daemon-reload
