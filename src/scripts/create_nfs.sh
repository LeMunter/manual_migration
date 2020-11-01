#!/bin/bash
#Login to openstack client
source /keys/am223yd-1dv032-ht20-openrc.sh

#name=$(jq -r '.[] | select(."name" == "gw") | ."name"' /mounted/server_vars.json)
name="testarnfs"
flavor=$(jq -r '.[] | select(."name" == "nfs") | ."flavor"' /mounted/server_vars.json)
image=$(jq -r '.[] | select(."name" == "nfs") | ."image"' /mounted/server_vars.json)
initFile=$(jq -r '.[] | select(."name" == "nfs") | ."init_file"' /mounted/server_vars.json)
key=$(jq -r '.[] | select(."name" == "nfs") | ."key"' /mounted/server_vars.json)
network=$(jq -r '.[] | select(."name" == "nfs") | ."network"' /mounted/server_vars.json)

#Get gateways float-ip
gwIP=$(jq -r '.[] | select(."name" == "gw") | ."float_ip"' /mounted/server_vars.json)


echo "Name: $name"
echo "Flavor: $flavor"
echo "Image: $image"
echo "Init File: $initFile"
echo "Key: $key"
echo "Network: $network"


echo "Creating server"
openstack server create --image "$image" --flavor "$flavor" --availability-zone Education --security-group default --key-name "$key" --network "$network" --user-data /mounted/"$initFile" "$name"

var=$(openstack server show -f value -c status $name)
while [ "$var" != "ACTIVE" ];
  do
    echo "Server is still building.. retrying in 5 seconds"
    sleep 5
    var=$(openstack server show -f value -c status $name)
done

fixedIp=$(openstack server show $name -f json | jq -r '.addresses' | sed 's/.*=//')
echo "Fixed IP: $fixedIp"
# shellcheck disable=SC2046
cat <<< $(jq '.[1].ip ="'"$fixedIp"'"' /mounted/server_vars.json) > /mounted/server_vars.json


#Add host when netcat successfully scan port 22
echo "Scanning port 22"
until ssh "$gwIP" nc -z -v "$fixedIp" 22 ; do
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