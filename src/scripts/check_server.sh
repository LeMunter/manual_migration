#!/bin/bash

name="$1"
server="$2"

echo -n "building $name"
dot="."
i=0
var=$(openstack server show -f value -c status "$name")
while [ "$var" != "ACTIVE" ];
  do
    echo -n $dot
    sleep 2
    ((i=i+1))
    if [ "$i" == 6 ]
      then
      echo "Rebuilding $name"
      openstack server delete "$name"
      sleep 10
      eval "$server"
      i=0
    fi
    # shellcheck disable=SC2086
    var=$(openstack server show -f value -c status $name)
done
echo ""