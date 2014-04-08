#!/bin/bash

DRUPAL_DB_NAME="drupal"
DRUPAL_DB_USER="drupal"
MYSQL_PASSWORD="drupal"
DRUPAL_PASSWORD="drupal"
DRUPAL_PATH="/var/www/"

# Start mysql
/usr/bin/mysqld_safe & 
sleep 3s

mysqladmin -u root password $MYSQL_PASSWORD 
mysql -uroot -p$MYSQL_PASSWORD <<EOT
	CREATE DATABASE $DRUPAL_DB_NAME; 
	GRANT ALL PRIVILEGES ON $DRUPAL_DB_NAME.* TO '$DRUPAL_DB_USER'@'localhost' IDENTIFIED BY '$DRUPAL_PASSWORD'; 
	FLUSH PRIVILEGES;
EOT

sed -i 's/AllowOverride None/AllowOverride All/' /etc/apache2/sites-available/default
a2enmod rewrite vhost_alias
cd $DRUPAL_PATH

cat sites/default/default.settings.php - > sites/default/settings.php <<EOT
\$databases['default']['default'] = array(
'database' => '$DRUPAL_DB_NAME',
'username' => '$DRUPAL_DB_USER',
'password' => '$DRUPAL_PASSWORD',
'host' => 'localhost',
'driver' => 'mysql',
'port' => 3306,
'prefix' => '',
);
EOT

drush sql-cli < /var/shared/sites/wedding/db/ivan_wedding.sql 
# drush site-install standard -y --account-name=admin --account-pass=admin --db-url="mysqli://drupal:${DRUPAL_PASSWORD}@localhost:3306/drupal"

killall mysqld
sleep 10s
