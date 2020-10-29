#!/bin/bash
name="ws1"
floatIp="194.47.206.29"
eval "$(ssh-agent -s)"

#Removing old key
rm ~/.ssh/known_hosts

echo "Creating DNS servers"
openstack server create "$name" --image ca4bec1a-ac25-434f-b14c-ad8078ccf39f --flavor c1-r1-d20 --availability-zone Education --security-group a7dba54e-1efd-4eab-96e0-82dd3536bc24 --key-name am223yd-1dv031_Keypair
openstack server show -f value -c status $name


var=$(openstack server show -f value -c status $name)
while [ $var != "ACTIVE" ];
  do
    sleep 5
    var=$(openstack server show -f value -c status $name)
done

echo "Assigning float ip"
openstack server add floating ip "$name" "$floatIp"

echo "Adding known hosts"
#Add to known hosts
until nc -z -v $floatIp 22 ; do
  echo "Server is still building.. retrying in 10 seconds"
  sleep 10
done
#Add host when netcat successfully scan port 22
ssh-keyscan -H "$floatIp" >> ~/.ssh/known_hosts

sleep 1
echo "Configuring webserver"
bash /mounted/scripts/config_ws.sh "$floatIp"

#Install wordpress and mysql
bash /mounted/scripts/wp_install.sh "$floatIp"
