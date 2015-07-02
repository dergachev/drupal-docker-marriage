**NOTE**: See https://github.com/evolvingweb/drupal-docker-marriage for a more recent version of this project.

drupal-docker-marriage [![Circle CI](https://circleci.com/gh/dergachev/drupal-docker-marriage.png?style=badge)](https://circleci.com/gh/dergachev/drupal-docker-marriage)
======================

An example of how to deploy a simple, wedding-themed Drupal site via Docker.

Installation
------------

First lets clone this repo:

```bash
# clone the repo
git clone https://github.com/dergachev/drupal-docker-marriage.git
cd drupal-docker-marriage
```

Now, assuming you aren't running docker locally, download [vagrant 1.4+](http://www.vagrantup.com/downloads.html) and [virtualbox](http://www.vagrantup.com/downloads.html) then use the provided Vagrantfile to spin up a VM that's running docker:

```bash
vagrant up
vagrant ssh
cd /vagrant
```

Confirm that you can run docker:

```bash
# See the list of running docker containers (there shouldn't be any yet)
docker ps

# Interactively run bash in a docker container from the "ubuntu" image
# on first run, will download 'ubuntu' from index.docker.io
docker run -t -i ubuntu /bin/bash

# ubuntu should appear
docker images
```

Now let's build our own docker image from the included [Dockerfile](https://github.com/dergachev/drupal-docker-marriage/blob/master/Dockerfile):

```
# Create ~/.ssh/id_rsa, ~/.ssh/id_rsa.pub (so we can later connect to the container with this).
ssh-keygen
# Place the public key where Dockerfile knows about.
cp ~/.ssh/id_rsa.pub ./deploy/id_rsa.pub

# Creates a docker image from Dockerfile in the current directory (.),
# assigns it a tag of "drupal-docker-marriage".
docker build -t drupal-docker-marriage .
```

If the build failed at a step and you'd like to launch bash inside the image
created at the last successful step:

```bash
# if the above failed at some step and we want to debug, the following will 
LATEST_IMAGE_ID=$(docker images -q | head -n 1) docker run -t -i $LATEST_IMAGE_ID /bin/bash
```

Once the build succeeds, you can run a container from the newly created image:

```bash
# should show drupal-docker-marriage
docker images -tree

# -name marriage  =>  Set container name to be 'marriage'; can be used interchangably with container ID
# -d              =>  Run in background
# -p 8080:80      =>  Forward DOCKER_CONTAINER_IP:80 to DOCKER_HOST_IP:8080
docker run -name marriage -d -p 8080:80 -p 9022:22 drupal-docker-marriage

# List running containers:
docker ps

# List stopped or aborted containers: (good for debugging)
docker ps -a
```

Once the container is running, visit the Drupal site at [http://localhost:8080](http://localhost:8080).
To connect to it via SSH:

```bash
ssh root@localhost -p 9022
```

To simplify the above steps, I provide a useful
[Makefile](https://github.com/dergachev/drupal-docker-marriage/blob/master/Makefile):

```bash
# build the image
make build

# run the container
make run

# SSH into the running container
make ssh

# remove snapshots of all stopped containers, remove all untagged images.
make clean

# debug helper: launch bash in latest created image
make run_bash_latest

# stop running container and destroy its snapshot; WILL DESTROY DATA
make destroy
```

Deployment on Digital Ocean
---------------------------

This simple Drupal site can be easily hosted for $5/month with Digital Ocean's 512MB droplet plan.
Here's how I deployed [http://ivanandyun.com](http://ivanandyun.com):

* signed up on digitalocean, created 512MB droplet ($5/month)
* hostname: ivanandyun.com
* image: docker 0.8 appliance
* credentials: uploaded my own SSH public key to digitalocean, associated with droplet
* assigned its IP (192.34.56.125) to ivanandyun.com, using my own DNS server

Now to SSH into my new docker appliance, build the image, and deploy the container:

```
ssh root@ivanandyun.com

apt-get install -y curl vim git make
apt-get install -y squid-deb-proxy

git clone https://github.com/dergachev/docker-drupal-marriage.git
cd docker-drupal-marriage

make build
make run

make ssh
```

At this point, I can visit http://ivanandyun.com:8080 and see a Drupal site.
Tweak the Makefile if you want it on port 80.
