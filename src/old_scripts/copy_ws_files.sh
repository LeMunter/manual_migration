#!/bin/bash
ip="$1"

  echo "#########COPY WS FILES##########"
  #Copy files to server
  scp /mounted/ws_config/acmea.am223yd-1dv031.devopslab.xyz.conf ubuntu@"$ip":

  ssh ubuntu@"$ip" /bin/bash << HERE
      sudo mv acmea.am223yd-1dv031.devopslab.xyz.conf /etc/apache2/sites-available
      sudo a2ensite acmea.am223yd-1dv031.devopslab.xyz.conf
      sudo service apache2 reload
HERE
