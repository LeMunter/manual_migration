#!/bin/bash
name="test"
eval "$(ssh-agent -s)"
key=$(openstack keypair list -f json | jq -r '.[].Name')
echo "$key"

rm ~/.ssh/known_hosts

#Create floating ip
#openstack floating ip create public

echo "Creating server"
openstack server create "$name" --image ca4bec1a-ac25-434f-b14c-ad8078ccf39f --flavor c1-r1-d10 --availability-zone Education --security-group 571195c2-27b2-4d4e-bb4c-36f48879e2e3 --key-name "$key" --network kub_net --user-data /mounted/scripts/cloud-init.sh --wait
#openstack server show -f value -c status $name


var=$(openstack server show -f value -c status $name)
while [ "$var" != "ACTIVE" ];
  do
    echo "Server is still building.. retrying in 5 seconds"
    sleep 5
    var=$(openstack server show -f value -c status $name)
done

echo "Assigning float ip"
floatIp=$(openstack floating ip list -f value -c "Floating IP Address")
openstack server add floating ip "$name" "$floatIp"

#Add host when netcat successfully scan port 22
until nc -z -v "$floatIp" 22 ; do
  echo "Server is still building.. retrying in 10 seconds"
  sleep 10
done

echo "Adding known hosts"
ssh-keyscan -H "$floatIp" >> ~/.ssh/known_hosts

