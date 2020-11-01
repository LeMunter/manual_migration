#!/bin/bash
#Login to openstack client
source /keys/am223yd-1dv032-ht20-openrc.sh

#name=$(jq -r '.[] | select(."name" == "gw") | ."name"' /mounted/server_vars.json)
name="testarnfs"
flavor=$(jq -r '.[] | select(."name" == "gw") | ."flavor"' /mounted/server_vars.json)
image=$(jq -r '.[] | select(."name" == "gw") | ."image"' /mounted/server_vars.json)
initFile=$(jq -r '.[] | select(."name" == "gw") | ."init_file"' /mounted/server_vars.json)
key=$(jq -r '.[] | select(."name" == "gw") | ."key"' /mounted/server_vars.json)
network=$(jq -r '.[] | select(."name" == "gw") | ."network"' /mounted/server_vars.json)
#Get a float ip without an associated fixed ip
gateIP=$(jq -r '.[] | select(."name" == gw) | ."float_ip"' /mounted/server_vars.json)
sg=$(openstack security group list -f json | jq -r '.[] | select(."Name" == "SSH") | ."Name"')


echo "Name: $name"
echo "Security Group: $sg"
echo "Flavor: $flavor"
echo "Image: $image"
echo "Init File: $initFile"
echo "Key: $key"
echo "Network: $network"


echo "Creating server"
openstack server create --image "$image" --flavor "$flavor" --availability-zone Education --security-group "$sg" --security-group default --key-name "$key" --network "$network" "$name" --user-data /mounted/"$initFile"

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
cat <<< $(jq '.[0].ip ="'"$fixedIp"'"' /mounted/server_vars.json) > /mounted/server_vars.json


#Add host when netcat successfully scan port 22
echo "Scanning port 22"
until ssh 194.47.177.127 nc -z -v "$fixedIp" 22 ; do
  echo "Server is still building.. retrying in 10 seconds"
  sleep 10
done


#Remove old known host if it exists
ssh 194.47.177.127 ssh-keygen -R "$floatIp"

echo "Adding known hosts"
ssh 194.47.177.127 ssh-keyscan -H "$floatIp" >> ~/.ssh/known_hosts

#ssh -J 194.47.177.127 172.16.0.20 cloud-init status -w

#echo "Waiting for cloud init script"
#ssh "$floatIp" cloud-init status -w
echo "done"