#!/bin/bash
/usr/bin/mysqld_safe & 
sleep 3

cd /var/www/
drush uli
chown -R www-data:www-data .
