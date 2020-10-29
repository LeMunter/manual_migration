#!/bin/bash
ip="$1"

ssh ubuntu@"$ip" /bin/bash << HERE
  sudo apt update && sudo apt -y upgrade
  sudo apt-get update && sudo apt-get install -y apache2 php libapache2-mod-php mariadb-server mariadb-client php-mysql
  sudo ufw allow 'Apache Full'
  sudo ufw allow OpenSSH
  sudo a2dissite 000-default.conf
  sudo mkdir -p /var/www/html/acmea.am223yd-1dv031.devopslab.xyz
  sudo chown -R $USER:$USER /var/www/html/acmea.am223yd-1dv031.devopslab.xyz
  sudo chmod -R 755 /var/www
  sudo ufw --force enable
HERE

bash /mounted/scripts/copy_ws_files.sh "$ip"
