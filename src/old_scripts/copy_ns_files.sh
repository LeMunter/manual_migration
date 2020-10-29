#!/bin/bash
ip="$1"

if [ "$ip" == 194.47.206.52 ]; then
  echo "copy ns1"
  #Copy files to server
  scp /mounted/dns_config/master/named.conf.options ubuntu@"$ip":
  scp /mounted/dns_config/master/named.conf.local ubuntu@"$ip":
  scp /mounted/dns_config/master/db.am223yd-1dv031.devopslab.xyz ubuntu@"$ip":

  #Copy files to the right place in the server
  ssh ubuntu@"$ip" /bin/bash << HERE
      sudo mv named.conf.options /etc/bind
      sudo mv named.conf.local /etc/bind
      sudo mkdir /etc/bind/zones
      sudo mv db.am223yd-1dv031.devopslab.xyz /etc/bind/zones
      sudo service bind9 restart
HERE
elif [ "$ip" == 194.47.206.46 ]; then
  echo "copy ns2"
  #Copy files to server
  scp /mounted/dns_config/slave/named.conf.options ubuntu@"$ip":
  scp /mounted/dns_config/slave/named.conf.local ubuntu@"$ip":
  #Copy files to the right place in the server
  ssh ubuntu@"$ip" /bin/bash << HERE
      sudo mv named.conf.options /etc/bind
      sudo mv named.conf.local /etc/bind
      sudo service bind9 restart
HERE
else
  echo "no valid ip"
fi
