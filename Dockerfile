# docker Drupal
#
# VERSION       0.1
# DOCKER-VERSION        0.4

FROM    ubuntu:latest

RUN echo "deb http://archive.ubuntu.com/ubuntu raring main restricted universe multiverse" > /etc/apt/sources.list
RUN apt-get update

RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -s /bin/true /sbin/initctl

RUN DEBIAN_FRONTEND=noninteractive apt-get -y install git mysql-client mysql-server apache2 libapache2-mod-php5 pwgen python-setuptools vim-tiny php5-mysql php-apc php5-gd php5-memcache memcached drush mc

RUN apt-get clean
RUN easy_install supervisor
 
RUN echo "postfix postfix/mailname string ivanandyun.com" | debconf-set-selections
RUN echo "postfix postfix/main_mailer_type string 'Internet Site'" | debconf-set-selections
RUN apt-get install -y postfix

RUN apt-get install -y curl git vim

# RUN apt-get install -y ssh-import-id; ssh-import-id gh:dergachev
RUN apt-get install -y openssh-server

RUN rm -rf /var/www/
ADD ./site /var/shared/sites/wedding/site
RUN ln -s /var/shared/sites/wedding/site /var/www
RUN chmod a+w /var/www/sites/default ; mkdir /var/www/sites/default/files ; chown -R www-data:www-data /var/www/

ADD ./db /var/shared/sites/wedding/db
ADD ./deploy/pre-deploy.sh /pre-deploy.sh
RUN /bin/bash /pre-deploy.sh

ADD ./deploy/post-deploy.sh /post-deploy.sh
RUN /bin/bash /post-deploy.sh

# now add all the rest of the project because "ADD . /var/shared/sites/wedding" invalidates caching
ADD ./.git /var/shared/sites/wedding/.git
ADD ./deploy /var/shared/sites/wedding/deploy
ADD ./Makefile /var/shared/sites/wedding/Makefile
ADD ./Vagrantfile /var/shared/sites/wedding/Vagrantfile
ADD ./Dockerfile /var/shared/sites/wedding/Dockerfile

# install public SSH key
ADD ./deploy/id_rsa.pub /root/id_rsa.pub
RUN mkdir -p /root/.ssh; chmod 700 /root/.ssh; cat /root/id_rsa.pub >> /root/.ssh/authorized_keys; chmod 600 /root/.ssh/authorized_keys

ADD ./deploy/foreground.sh /etc/apache2/foreground.sh
ADD ./deploy/supervisord.conf /etc/supervisord.conf
RUN chmod 755 /etc/apache2/foreground.sh
RUN mkdir -p /var/run/sshd; mkdir -p /var/log/supervisor

EXPOSE 80
EXPOSE 22
CMD ["supervisord", "-n"]
# CMD ["/bin/bash", "/start.sh"]
