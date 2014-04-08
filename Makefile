build:
	docker build -t dergachev/ivanandyun .

# runs the last SUCCESSFUL image
run:
	docker run -d -p 80:80 -p 9022:22 dergachev/ivanandyun

stop:
	docker stop $$(docker ps | grep dergachev/ivanandyun | awk '{print $$1}')

# kill all containers, remove all untagged images
destroy:
	docker ps -a -q | xargs docker rm
	docker images -a | grep "^<none>" | awk '{print $$3}' | xargs docker rmi

# SSH into latest created image
latest:
	docker run -t -i $$(docker images -q | head -n 1) /bin/bash

ssh:
	ssh root@localhost -p 9022

go: build run
