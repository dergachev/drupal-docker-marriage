#==================================================================================
# Initial configuration
#==================================================================================
FROM  ubuntu:saucy

# Work-around for the fact that docker doesn't run upstart (or other daemons)
# Otherwise 'apt-get install apache2' will fail when it tries to run 'service start apache2'
RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -s -f /bin/true /sbin/initctl

# If host is running squid-deb-proxy, populate /etc/apt/apt.conf.d/30proxy
RUN route -n | awk '/^0.0.0.0/ {print $2}' > /tmp/host_ip.txt
RUN echo "HEAD /" | nc `cat /tmp/host_ip.txt` 8000 | grep squid-deb-proxy \
  && (echo "Acquire::http::Proxy \"http://$(cat /tmp/host_ip.txt):8000\";" > /etc/apt/apt.conf.d/30proxy) \
  || echo "No squid-deb-proxy detected"

# setup extended package repo
RUN echo "deb http://archive.ubuntu.com/ubuntu saucy main restricted universe multiverse" > /etc/apt/sources.list
RUN apt-get update

#==================================================================================
# Install packages
#==================================================================================

# Install lamp packages
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install git mysql-client \
  mysql-server apache2 libapache2-mod-php5 php5-mysql php-apc php5-gd \
  php5-memcache php5-json memcached

# Install other utilities
RUN apt-get install -y curl git vim
RUN apt-get install -y openssh-server pwgen

# Install and configure supervisord
# See http://docs.docker.io/en/latest/examples/using_supervisord/
RUN apt-get install -y supervisor
ADD ./deploy/supervisord.conf /etc/supervisord.conf
RUN mkdir -p /var/run/sshd; mkdir -p /var/log/supervisor

# Install composer and drush
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer
RUN composer global require drush/drush:6.*
RUN ln -sf /.composer/vendor/drush/drush/drush /usr/bin/drush

# Install and configure postfix for sending of emails
RUN echo "postfix postfix/mailname string example.com" | debconf-set-selections
RUN echo "postfix postfix/main_mailer_type string 'Internet Site'" | debconf-set-selections
RUN apt-get install -y postfix

#==================================================================================
# Install codebase, configure apache
#==================================================================================

# Setup static directory for serving files, fix perms
ADD ./site /var/shared/sites/wedding/site
RUN rm -rf /var/www/; ln -s /var/shared/sites/wedding/site /var/www
RUN chmod a+w /var/www/sites/default ; mkdir /var/www/sites/default/files ; chown -R www-data:www-data /var/www/

# Apache vhost configuration
RUN sed -i '/<VirtualHost/a \\t<Directory /var/www/>\n\t\tAllowOverride All\n\t</Directory>' /etc/apache2/sites-available/000-default.conf
RUN a2enmod rewrite vhost_alias

#==================================================================================
# Initialize the database
#==================================================================================

# Load drupal db from dump
ADD ./db /var/shared/sites/wedding/db/
ADD ./deploy/pre-deploy.sh /tmp/pre-deploy.sh
RUN /bin/bash /tmp/pre-deploy.sh

# Post-load db customizations
ADD ./deploy/post-deploy.sh /tmp/post-deploy.sh
RUN /bin/bash /tmp/post-deploy.sh

#==================================================================================
# Install public SSH key
#==================================================================================

ADD ./deploy/id_rsa.pub /root/.ssh/id_rsa.pub
RUN cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys
RUN chmod 700 /root/.ssh; chmod 600 /root/.ssh/authorized_keys
# workaround for docker/saucy SSH bug; see https://gist.github.com/gasi/5691565
RUN sed -ri 's/UsePAM yes/UsePAM no/' /etc/ssh/sshd_config

#==================================================================================
# Finally...
#==================================================================================

# This invalidates caching of subsequent steps, so we do this last.
ADD . /var/shared/sites/wedding

EXPOSE 80
EXPOSE 22
CMD ["supervisord", "-n"]
