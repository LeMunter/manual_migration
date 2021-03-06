#!/bin/bash

server_vars="$1"
os_vars="$2"
if test -z "$server_vars"
then
  echo "Must provide server variables"
  exit 1
fi
#Login to openstack client
source /keys/am223yd-1dv032-ht20-openrc.sh

name=$(jq -r '.[] | select(."name" == "gw") | ."name"' "$server_vars")
flavor=$(jq -r '.[] | select(."name" == "gw") | ."flavor"' "$server_vars")
image=$(jq -r '.[] | select(."name" == "gw") | ."image"' "$server_vars")
initFile=$(jq -r '.[] | select(."name" == "gw") | ."init_file"' "$server_vars")
key=$(jq -r '.[] | select(."name" == "gw") | ."key"' "$server_vars")
network=$(jq -r '.network' "$os_vars")
sg=$(jq -r '.sg[0]' "$os_vars")


echo "Name: $name"
echo "Security Group: $sg"
echo "Flavor: $flavor"
echo "Image: $image"
echo "Init File: $initFile"
echo "Key: $key"
echo "Network: $network"


echo "Creating server"
server=$"openstack server create --image $image --flavor $flavor --availability-zone Education --security-group $sg --security-group default --key-name $key --network $network --user-data /mounted/servers/gw/$initFile $name"
eval $server

bash /mounted/scripts/check_server.sh "$name" "$server"

#Get fixed ip
fixedIp=$(openstack server show "$name" -f json | jq -r '.addresses' | sed 's/.*=//')
echo "Fixed IP: $fixedIp"

#Assing fixed ip to server-variables
# shellcheck disable=SC2046
cat <<< $(jq '.[0].ip ="'"$fixedIp"'"' "$server_vars") > "$server_vars"

#floatIp=$(openstack floating ip list -f json | jq -r '.[] | select(."Fixed IP Address" == null) | ."Floating IP Address"' | sed -n 1p)
floatIp=$(jq -r '.float_ips[0]' /mounted/os_vars.json)

#Check that the floating ip is not empty
if test -z "$floatIp"
then
  echo "Creating new floating IP"
  floatIp=$(openstack floating ip create public -f json | jq '.floating_ip_address')
fi

#Assing float ip to server-variables
echo "Assigning float ip: $floatIp"
# shellcheck disable=SC2046
cat <<< $(jq '.[0].float_ip = "'"$floatIp"'"' "$server_vars") > "$server_vars"

#Assign float ip to server
openstack server add floating ip "$name" "$floatIp"

#Add host when netcat successfully scan port 22
until nc -z -v "$floatIp" 22 ;
  do
  echo "Server is still building.. retrying in 10 seconds"
  sleep 10
done

#Remove the old known host (if it exists)
ssh-keygen -R "$floatIp"

echo "Adding known hosts"
ssh-keyscan -H "$floatIp" >> ~/.ssh/known_hosts

ssh-copy-id -i ~/.ssh/id_rsa ubuntu@$floatIp
