#!/bin/bash

#server_vars="$1"
#if test -z "$server_vars"
#then
#  echo "Must provide server variables"
#  exit 1
#fi

server_vars="/mounted/server_vars.json"
#Login to openstack client
source /keys/am223yd-1dv032-ht20-openrc.sh

name1="node-1"
name2="node-2"
name3="node-3"

flavor=$(jq -r '.[] | select(."name" == "node-1") | ."flavor"' "$server_vars")
image=$(jq -r '.[] | select(."name" == "node-1") | ."image"' "$server_vars")
initFile=$(jq -r '.[] | select(."name" == "node-1") | ."init_file"' "$server_vars")
key=$(jq -r '.[] | select(."name" == "node-1") | ."key"' "$server_vars")
network=$(jq -r '.[] | select(."name" == "node-1") | ."network"' "$server_vars")

#Get gateway float-ip
gwIP=$(jq -r '.[] | select(."name" == "gw") | ."float_ip"' "$server_vars")


echo "Name: $name1"
echo "Name: $name2"
echo "Name: $name3"
echo "Flavor: $flavor"
echo "Image: $image"
echo "Init File: $initFile"
echo "Key: $key"
echo "Network: $network"

server1=$"openstack server create --image $image --flavor $flavor --availability-zone Education --security-group default --key-name $key --network $network --user-data /mounted/servers/nodes/$initFile $name1"
server2=$"openstack server create --image $image --flavor $flavor --availability-zone Education --security-group default --key-name $key --network $network --user-data /mounted/servers/nodes/$initFile $name2"
server3=$"openstack server create --image $image --flavor $flavor --availability-zone Education --security-group default --key-name $key --network $network --user-data /mounted/servers/nodes/$initFile $name3"
eval $server1
eval $server2
eval $server3

bash /mounted/scripts/check_server.sh "$name1" "$server1"
bash /mounted/scripts/check_server.sh "$name2" "$server2"
bash /mounted/scripts/check_server.sh "$name3" "$server3"


fixedIp1=$(openstack server show $name1 -f json | jq -r '.addresses' | sed 's/.*=//')
fixedIp2=$(openstack server show $name2 -f json | jq -r '.addresses' | sed 's/.*=//')
fixedIp3=$(openstack server show $name3 -f json | jq -r '.addresses' | sed 's/.*=//')


#Add fixed-ip to server-variables
cat <<< $(jq '.[4].ip ="'"$fixedIp1"'"' "$server_vars") > "$server_vars"
cat <<< $(jq '.[5].ip ="'"$fixedIp2"'"' "$server_vars") > "$server_vars"
cat <<< $(jq '.[6].ip ="'"$fixedIp3"'"' "$server_vars") > "$server_vars"

#Add host when netcat successfully scan port 22
echo "Scanning port 22"
until ssh "$gwIP" nc -z -v "$fixedIp1" 22 ;
  do
  echo "Server is still building.. retrying in 10 seconds"
  sleep 10
done

until ssh "$gwIP" nc -z -v "$fixedIp2" 22 ;
  do
  echo "Server is still building.. retrying in 10 seconds"
  sleep 10
done

until ssh "$gwIP" nc -z -v "$fixedIp3" 22 ;
  do
  echo "Server is still building.. retrying in 10 seconds"
  sleep 10
done

#Remove old known host if it exists
ssh "$gwIP" ssh-keygen -R "$fixedIp1"
ssh "$gwIP" ssh-keygen -R "$fixedIp2"
ssh "$gwIP" ssh-keygen -R "$fixedIp3"

echo "Adding known hosts"
ssh "$gwIP" ssh-keyscan -H "$fixedIp1" >> ~/.ssh/known_hosts
ssh "$gwIP" ssh-keyscan -H "$fixedIp2" >> ~/.ssh/known_hosts
ssh "$gwIP" ssh-keyscan -H "$fixedIp3" >> ~/.ssh/known_hosts
