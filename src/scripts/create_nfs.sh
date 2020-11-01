#!/bin/bash

server_vars="$1"
if test -z "$server_vars"
then
  echo "Must provide server variables"
  exit 1
fi
#Login to openstack client
source /keys/am223yd-1dv032-ht20-openrc.sh

name=$(jq -r '.[] | select(."name" == "gw") | ."name"' "$server_vars")
flavor=$(jq -r '.[] | select(."name" == "nfs") | ."flavor"' "$server_vars")
image=$(jq -r '.[] | select(."name" == "nfs") | ."image"' "$server_vars")
initFile=$(jq -r '.[] | select(."name" == "nfs") | ."init_file"' "$server_vars")
key=$(jq -r '.[] | select(."name" == "nfs") | ."key"' "$server_vars")
network=$(jq -r '.[] | select(."name" == "nfs") | ."network"' "$server_vars")

#Get gateways float-ip
gwIP=$(jq -r '.[] | select(."name" == "gw") | ."float_ip"' "$server_vars")


echo "Name: $name"
echo "Flavor: $flavor"
echo "Image: $image"
echo "Init File: $initFile"
echo "Key: $key"
echo "Network: $network"


echo "Creating server"
openstack server create --image "$image" --flavor "$flavor" --availability-zone Education --security-group default --key-name "$key" --network "$network" --user-data /mounted/servers/nfs/"$initFile" "$name"

var=$(openstack server show -f value -c status $name)
dot="."
while [ "$var" != "ACTIVE" ];
  do
    echo $dot
    dot+="."
    sleep 3
    var=$(openstack server show -f value -c status $name)
done

fixedIp=$(openstack server show $name -f json | jq -r '.addresses' | sed 's/.*=//')
echo "Fixed IP: $fixedIp"
# shellcheck disable=SC2046
cp /mounted/server_vars.json /mounted/server_vars_backup.json
# shellcheck disable=SC2046
cat <<< $(jq '.[1].ip ="'"$fixedIp"'"' "$server_vars") > "$server_vars"


#Add host when netcat successfully scan port 22
echo "Scanning port 22"
until ssh "$gwIP" nc -z -v "$fixedIp" 22 ;
  do
  echo "Server is still building.. retrying in 10 seconds"
  sleep 10
done

#Remove old known host if it exists
ssh "$gwIP" ssh-keygen -R "$fixedIp"

echo "Adding known hosts"
ssh "$gwIP" ssh-keyscan -H "$fixedIp" >> ~/.ssh/known_hosts

echo "Waiting for cloud init script"
ssh -J "$gwIP" "$fixedIp" cloud-init status -w

#ssh "$floatIp" cloud-init status -w