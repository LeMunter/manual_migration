#!/bin/bash
#Login to openstack client
source /keys/am223yd-1dv032-ht20-openrc.sh

name=$(jq -r '.[] | select(."name" == "gw") | ."name"' /mounted/server_vars.json)
flavor=$(jq -r '.[] | select(."name" == "gw") | ."flavor"' /mounted/server_vars.json)
image=$(jq -r '.[] | select(."name" == "gw") | ."image"' /mounted/server_vars.json)
initFile=$(jq -r '.[] | select(."name" == "gw") | ."init_file"' /mounted/server_vars.json)
key=$(jq -r '.[] | select(."name" == "gw") | ."key"' /mounted/server_vars.json)
#Get a float ip without an associated fixed ip
floatIp=$(openstack floating ip list -f json | jq -r '.[] | select(."Fixed IP Address" == null) | ."Floating IP Address"')
sg=$(openstack security group list -f json | jq -r '.[] | select(."Name" == "SSH") | ."ID"')


echo "Name: $name"
echo "Float ip: $floatIp"
echo "SG: $sg"
echo "Flavor: $flavor"
echo "Image: $image"
echo "Init File: $initFile"
echo "Key: $key"


#echo "Creating server"
#openstack server create "$name" --image "$image" --flavor "$flavor" --availability-zone Education --security-group "$sg" --key-name "$key" --network kub_net --user-data /mounted/"$initFile" --wait
