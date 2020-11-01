#!/bin/bash
#Login to openstack client
source /keys/am223yd-1dv032-ht20-openrc.sh

#name=$(jq -r '.[] | select(."name" == "gw") | ."name"' /mounted/server_vars.json)
name="testgw"
flavor=$(jq -r '.[] | select(."name" == "gw") | ."flavor"' /mounted/server_vars.json)
image=$(jq -r '.[] | select(."name" == "gw") | ."image"' /mounted/server_vars.json)
initFile=$(jq -r '.[] | select(."name" == "gw") | ."init_file"' /mounted/server_vars.json)
key=$(jq -r '.[] | select(."name" == "gw") | ."key"' /mounted/server_vars.json)
network=$(jq -r '.[] | select(."name" == "gw") | ."network"' /mounted/server_vars.json)

#Check if a ssh security already exists. Otherwise creating one
sg=$(openstack security group list -f json | jq -r '.[] | select(."Name" == "SSH2") | ."Name"')
if test -z "$sg"
then
  echo "Creating new Security Group"
  sg=$(openstack security group create SSH2 -f json | jq -r '.name')
  openstack security group rule create SSH2 --protocol tcp --dst-port 22
fi
# shellcheck disable=SC2046
cat <<< $(jq '.[0].sg = "'"$sg"'"' /mounted/server_vars.json) > /mounted/server_vars.json


echo "Name: $name"
echo "Security Group: $sg"
echo "Flavor: $flavor"
echo "Image: $image"
echo "Init File: $initFile"
echo "Key: $key"
echo "Network: $network"

#Remove the old known host (if it exists)
ssh-keygen -R "$floatIp"


echo "Creating server"
openstack server create --image "$image" --flavor "$flavor" --availability-zone Education --security-group "$sg" --security-group default --key-name "$key" --network "$network" --user-data /mounted/servers/gw/"$initFile" "$name"

var=$(openstack server show -f value -c status $name)
while [ "$var" != "ACTIVE" ];
  do
    echo "Server is still building.. retrying in 5 seconds"
    sleep 5
    var=$(openstack server show -f value -c status $name)
done

#Get fixed ip
fixedIp=$(openstack server show $name -f json | jq -r '.addresses' | sed 's/.*=//')
echo "Fixed IP: $fixedIp"

#Assing fixed ip to server-variables
# shellcheck disable=SC2046
cp /mounted/server_vars.json /mounted/server_vars_backup.json
cat <<< $(jq '.[0].ip ="'"$fixedIp"'"' /mounted/server_vars.json) > /mounted/server_vars.json

#Check to see if there are any free float ips. Create a new otherwise
floatIp=$(openstack floating ip list -f json | jq -r '.[] | select(."Fixed IP Address" == null) | ."Floating IP Address"' | sed -n 1p)
if test -z "$floatIp"
then
  echo "Creating new floating IP"
  floatIp=$(openstack floating ip create public -f json | jq '.floating_ip_address')
fi

#Assing float ip to server-variables
echo "Assigning float ip: $floatIp"
cp /mounted/server_vars.json /mounted/server_vars_backup.json
cat <<< $(jq '.[0].float_ip = "'"$floatIp"'"' /mounted/server_vars.json) > /mounted/server_vars.json

#Assign float ip to server
openstack server add floating ip "$name" "$floatIp"

#Add host when netcat successfully scan port 22
until nc -z -v "$floatIp" 22 ; do
  echo "Server is still building.. retrying in 10 seconds"
  sleep 10
done
echo "Adding known hosts"
ssh-keyscan -H "$floatIp" >> ~/.ssh/known_hosts

#echo "Waiting for cloud init script"
#ssh "$floatIp" cloud-init status -w