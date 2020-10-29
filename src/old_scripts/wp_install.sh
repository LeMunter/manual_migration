#!/bin/bash
ip="$1"

echo "#########Enter a database name#########"
read -sr dbName
echo "$dbName saved"
echo "#########Enter a username#########"
read -sr name
echo "$name saved"
echo "#########Enter a password#########"
read -sr pass
echo "Password saved"

echo Installing mysql
ssh ubuntu@"$ip" /bin/bash << HERE
  sudo mysql
  DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
  DELETE FROM mysql.user WHERE User='';
  DELETE FROM mysql.db WHERE Db='test' OR Db='test_%';
  FLUSH PRIVILEGES;
  CREATE DATABASE $dbName;
  CREATE USER '$name'@'localhost' IDENTIFIED BY '$pass';
  GRANT ALL PRIVILEGES ON $dbName.* to $name@'localhost';
  FLUSH PRIVILEGES;
  exit
HERE

sleep 1

echo Installing wordpress
ssh ubuntu@"$ip" /bin/bash << HERE
  sudo wget -O /tmp/wordpress.tar.gz https://wordpress.org/latest.tar.gz
  sudo tar -xzvf /tmp/wordpress.tar.gz -C /tmp
  sudo cp /tmp/wordpress/wp-config-sample.php /tmp/wordpress/wp-config.php
  sudo cp -r /tmp/wordpress/. /var/www/html/acmea.am223yd-1dv031.devopslab.xyz/
  sudo chown -R www-data:www-data /var/www/html/acmea.am223yd-1dv031.devopslab.xyz

  sudo wget -qO wpsucli https://git.io/vykgu && sudo chmod +x ./wpsucli && sudo install ./wpsucli /usr/local/bin/wpsucli
  cd /var/www/html/acmea.am223yd-1dv031.devopslab.xyz
  sudo wpsucli
  sudo sed -i -e "s/database_name_here/$dbName/g" wp-config.php
  sudo sed -i -e "s/username_here/$name/g" wp-config.php
  sudo sed -i -e "s/password_here/$pass/g" wp-config.php
HERE
