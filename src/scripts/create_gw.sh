#!/bin/bash
#Login to openstack client
source /keys/am223yd-1dv032-ht20-openrc.sh

#name=$(jq -r '.[] | select(."name" == "gw") | ."name"' /mounted/server_vars.json)
name="testarigen"
flavor=$(jq -r '.[] | select(."name" == "gw") | ."flavor"' /mounted/server_vars.json)
image=$(jq -r '.[] | select(."name" == "gw") | ."image"' /mounted/server_vars.json)
initFile=$(jq -r '.[] | select(."name" == "gw") | ."init_file"' /mounted/server_vars.json)
key=$(jq -r '.[] | select(."name" == "gw") | ."key"' /mounted/server_vars.json)
network=$(jq -r '.[] | select(."name" == "gw") | ."network"' /mounted/server_vars.json)
#Get a float ip without an associated fixed ip
floatIp=$(openstack floating ip list -f json | jq -r '.[] | select(."Fixed IP Address" == null) | ."Floating IP Address"')
sg=$(openstack security group list -f json | jq -r '.[] | select(."Name" == "SSH") | ."Name"')


echo "Name: $name"
echo "Float ip: $floatIp"
echo "Security Group: $sg"
echo "Flavor: $flavor"
echo "Image: $image"
echo "Init File: $initFile"
echo "Key: $key"
echo "Network: $network"


#echo "Creating server"
openstack server create --image "$image" --flavor "$flavor" --availability-zone Education --security-group "$sg" --security-group default --key-name "$key" --network "$network" "$name" --user-data /mounted/base-init.sh

var=$(openstack server show -f value -c status $name)
while [ "$var" != "ACTIVE" ];
  do
    echo "Server is still building.. retrying in 5 seconds"
    sleep 5
    var=$(openstack server show -f value -c status $name)
done

echo "Assigning float ip"
openstack server add floating ip "$name" "$floatIp"