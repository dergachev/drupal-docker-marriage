deploy/id_rsa.pub:
	# Creating ./deploy/id_rsa.pub, which will be installed for SSH access to container
	test -e ~/.ssh/id_rsa.pub || ssh-keygen
	cp ~/.ssh/id_rsa.pub ./deploy/id_rsa.pub

build: deploy/id_rsa.pub
	docker build -t drupal-docker-marriage .

run:
	docker run -name marriage -d -p 8080:80 -p 9022:22 drupal-docker-marriage
	docker ps

# stop and remove snapshot running container; WILL DESTROY DATA
destroy:
	-docker stop marriage
	-docker rm marriage

# debug helper: launch bash in latest created image
run_bash_latest:
	docker run -t -i $$(docker images -q | head -n 1) /bin/bash

# SSH into the running container, by determining its port
ssh:
	ssh root@localhost -p $$(docker port marriage 22 | cut -d: -f2) -o ForwardAgent=yes -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no

# remove snapshots of all stopped containers, remove all untagged images
clean:
	docker ps -a -q | xargs docker rm
	docker images -a | grep "^<none>" | awk '{print $$3}' | xargs docker rmi
