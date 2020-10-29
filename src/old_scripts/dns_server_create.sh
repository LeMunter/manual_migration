#!/bin/bash
name="ns1"
name2="ns2"
floatIp="194.47.206.52"
floatIp2="194.47.206.46"
eval "$(ssh-agent -s)"

#Removing old key
rm ~/.ssh/known_hosts

echo "Creating DNS servers"
openstack server create "$name" --image ca4bec1a-ac25-434f-b14c-ad8078ccf39f --flavor c1-r05-d5 --availability-zone Education --security-group 47e6f57c-a6f4-4816-9123-9fa24e49e4e8 --key-name am223yd-1dv031_Keypair
openstack server create "$name2" --image ca4bec1a-ac25-434f-b14c-ad8078ccf39f --flavor c1-r05-d5 --availability-zone Education --security-group 47e6f57c-a6f4-4816-9123-9fa24e49e4e8 --key-name am223yd-1dv031_Keypair

var=$(openstack server show -f value -c status $name)
while [ $var != "ACTIVE" ];
  do
    sleep 5
    var=$(openstack server show -f value -c status $name)
done

echo "Assigning float ip"
openstack server add floating ip "$name" "$floatIp"
openstack server add floating ip "$name2" "$floatIp2"

echo "Adding known hosts"
#Add to known hosts
until nc -z -v $floatIp 22 && nc -z -v $floatIp2 22 ; do
  echo "Servers are still building.. retrying in 10 seconds"
  sleep 10
done
#Add hosts when netcat successfully scan port 22 on both servers
ssh-keyscan -H "$floatIp" >> ~/.ssh/known_hosts
ssh-keyscan -H "$floatIp2" >> ~/.ssh/known_hosts

sleep 1
echo "Starting DNS config script"
bash /mounted/scripts/add_dns_config.sh "$floatIp"
bash /mounted/scripts/add_dns_config.sh "$floatIp2"
