#!/bin/bash

server_vars="$1"
os_vars="$2"
if test -z "$server_vars"
then
  echo "Must provide server variables"
  exit 1
fi

server_vars="/mounted/server_vars.json"
#Login to openstack client
source /keys/am223yd-1dv032-ht20-openrc.sh

name=$(jq -r '.[] | select(."name" == "dr") | ."name"' "$server_vars")
flavor=$(jq -r '.[] | select(."name" == "dr") | ."flavor"' "$server_vars")
image=$(jq -r '.[] | select(."name" == "dr") | ."image"' "$server_vars")
initFile=$(jq -r '.[] | select(."name" == "dr") | ."init_file"' "$server_vars")
key=$(jq -r '.[] | select(."name" == "dr") | ."key"' "$server_vars")
network=$(jq -r '.network' "$os_vars")

#Get gateway float-ip
gwIP=$(jq -r '.[] | select(."name" == "gw") | ."float_ip"' "$server_vars")


echo "Name: $name"
echo "Flavor: $flavor"
echo "Image: $image"
echo "Init File: $initFile"
echo "Key: $key"
echo "Network: $network"


echo "Creating server"
server=$"openstack server create --image $image --flavor $flavor --availability-zone Education --security-group default --key-name $key --network $network --user-data /mounted/servers/registry/$initFile $name"
eval $server

bash /mounted/scripts/check_server.sh "$name" "$server"

fixedIp=$(openstack server show "$name" -f json | jq -r '.addresses' | sed 's/.*=//')
echo "Fixed IP: $fixedIp"

#Add fixed-ip to server-variables
cat <<< $(jq '.[2].ip ="'"$fixedIp"'"' "$server_vars") > "$server_vars"

#Update docker daemon
cat <<< $(jq '."insecure-registries"[0] ="'"$fixedIp"':'"5000"'"' /mounted/servers/master/daemon.json) > /mounted/servers/master/daemon.json

#Add host when netcat successfully scan port 22
echo "Scanning port 22"
bash /mounted/scripts/scan_port.sh "$gwIP" "$fixedIp"

#Remove old known host if it exists
ssh "$gwIP" ssh-keygen -R "$fixedIp"

echo "Adding known hosts"
ssh "$gwIP" ssh-keyscan -H "$fixedIp" >> ~/.ssh/known_hosts
