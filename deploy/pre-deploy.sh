#!/bin/bash

DRUPAL_DB_NAME="drupal"
DRUPAL_DB_USER="drupal"
MYSQL_PASSWORD=`pwgen -c -n -1 12`
DRUPAL_PASSWORD=`pwgen -c -n -1 12`

#This is so the passwords show up in logs.
echo mysql root password: $MYSQL_PASSWORD
echo drupal db password: $DRUPAL_PASSWORD

# Start mysql
/usr/bin/mysqld_safe & 
sleep 3s

cd /var/www/

echo "Creating empty mysql db; name: $DRUPAL_DB_NAME"
mysqladmin -u root password $MYSQL_PASSWORD 
mysql -uroot -p$MYSQL_PASSWORD <<EOT
	CREATE DATABASE $DRUPAL_DB_NAME; 
	GRANT ALL PRIVILEGES ON $DRUPAL_DB_NAME.* TO '$DRUPAL_DB_USER'@'localhost' IDENTIFIED BY '$DRUPAL_PASSWORD'; 
	FLUSH PRIVILEGES;
EOT

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

echo "Populating db: $DRUPAL_DB_NAME"
drush sql-cli < /var/shared/sites/wedding/db/ivan_wedding.sql 
# drush site-install standard -y --account-name=admin --account-pass=admin --db-url="mysqli://drupal:${DRUPAL_PASSWORD}@localhost:3306/drupal"

killall mysqld
sleep 10s
