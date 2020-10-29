#!/bin/bash
ip="$1"
nodeIp="$2"
nodeIp2="$3"
cp /mounted/nginx/acmeb.am223yd-1dv031.devopslab.xyz.conf acmeb.am223yd-1dv031.devopslab.xyz.conf
sed -i -e "s/ip1/$nodeIp/g" acmeb.am223yd-1dv031.devopslab.xyz.conf
sed -i -e "s/ip2/$nodeIp2/g" acmeb.am223yd-1dv031.devopslab.xyz.conf
scp /mounted/nginx/nginx.conf ubuntu@"$ip":
scp acmeb.am223yd-1dv031.devopslab.xyz.conf ubuntu@"$ip": && rm acmeb.am223yd-1dv031.devopslab.xyz.conf

ssh ubuntu@"$ip" /bin/bash << HERE
sudo mv nginx.conf /etc/nginx
sudo mv acmeb.am223yd-1dv031.devopslab.xyz.conf /etc/nginx/conf.d
sudo chown -R root /etc/nginx
sudo chgrp -R root /etc/nginx
sudo nginx -s reload
exit
HERE