.DEFAULT_GOAL := build

dest=/usr/share/comitup
plate=1

install:
        sudo install.sh

update:
	sudo apt update
	sudo apt upgrade comitup
	sudo cp web/comitupweb.py $(dest)/web/comitupweb.py
	sudo cp wel/templates/index.html $(dest)/web/templates/index.html
	sudo cp wel/templates/wifi.html $(dest)/web/templates/wifi.html

compile:
	docker build -f Dockerfile \
		--build-arg name=$(app) \
		--build-arg version=$(version) \
		--build-arg app=votion2_app \
		--build-arg url=$(url) \
		--rm -t $(lower_app):$(version) .

save:
	docker save $(lower_app):$(version) | gzip > ../$(lower_app).tgz

build: compile save

upload:
	scp ../$(lower_app)*.tgz cdruet@fundocker:/home/cdruet/apps/
	-rm ../$(lower_app)*.tgz

stop:
	-ssh cdruet@fundocker docker container rm -f $(lower_app) $(lower_app)_beat $(lower_app)_worker

prune:
	-ssh cdruet@fundocker docker image prune -f

import: stop
	ssh cdruet@fundocker docker load -i /home/cdruet/apps/$(lower_app).tgz
	ssh cdruet@fundocker docker tag $(lower_app):$(version) $(lower_app):latest
	-ssh cdruet@fundocker docker image prune -f
	-ssh cdruet@fundocker rm -f /home/cdruet/apps/$(lower_app).tgz
install: upload import

all: build install

compose: stop prune
	ssh cdruet@fundocker docker run -d \
		--name $(lower_app)_worker \
		-e "FLASK_URL=$(url)" \
		-e "LOGLEVEL=DEBUG" \
		-e "CELERY_ENABLE_UTC=1" \
		--restart=on-failure:10 \
		-it $(lower_app):latest ./boot_worker.sh
	ssh cdruet@fundocker docker run -d \
		--name $(lower_app)_beat \
		-e "FLASK_URL=$(url)" \
		-e "LOGLEVEL=WARNING" \
		-e "CELERY_ENABLE_UTC=1" \
		--link "$(lower_app)_worker" \
		--restart=on-failure:10 \
		-it $(lower_app):latest ./boot_beat.sh
	ssh cdruet@fundocker docker run -d \
		--name $(lower_app) \
		-e "LOGLEVEL=DEBUG" \
		-e "CELERY_ENABLE_UTC=1" \
		-p $(port):5000 \
		--link "$(lower_app)_beat" \
		--restart=on-failure:10 \
		-it $(lower_app):latest

expose:
	ssh cdruet@fundocker 'if grep -Fxq "$(url):$(port)" /home/cdruet/.reversepx; then : ; else echo "$(url):$(port) SSL=1" >> /home/cdruet/.reversepx; fi'

full: all compose expose

rclean: stop
	ssh cdruet@fundocker rm -f /home/cdruet/apps/$(lower_app).tgz

clean:
	-rm -f ../$(lower_app).tgz
	-docker images -a | grep "none" | awk '{print $3}' | xargs docker rmi -f
	-ssh cdruet@fundocker 'docker images -a | grep "none" | awk "{print $3}" | xargs docker rmi -f'

fullclean:
	docker images -a | grep "$(lower_app)" | awk '{print $3}' | xargs docker rmi -f




