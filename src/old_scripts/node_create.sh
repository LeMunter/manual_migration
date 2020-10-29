#!/bin/bash
nginxIP="194.47.206.62"
nginxName="nginx"
name1="node1"
name2="node2"
eval "$(ssh-agent -s)"

#Removing old key
rm ~/.ssh/known_hosts

echo "Creating servers"
openstack server create "$nginxName" --image ca4bec1a-ac25-434f-b14c-ad8078ccf39f --flavor c1-r1-d10 --availability-zone Education --security-group b3d26e22-3d65-4671-8375-59aae7c4c3fa --key-name am223yd-1dv031_Keypair
openstack server create "$name1" --image ca4bec1a-ac25-434f-b14c-ad8078ccf39f --flavor c1-r2-d10 --availability-zone Education --security-group b0248a6f-e60e-40fe-b321-735b8ab83f9d --key-name am223yd-1dv031_Keypair
openstack server create "$name2" --image ca4bec1a-ac25-434f-b14c-ad8078ccf39f --flavor c1-r2-d10 --availability-zone Education --security-group b0248a6f-e60e-40fe-b321-735b8ab83f9d --key-name am223yd-1dv031_Keypair

var=$(openstack server show -f value -c status $nginxName)
while [ $var != "ACTIVE" ]; do
    sleep 5
    var=$(openstack server show -f value -c status $nginxName)
done

echo "Assigning float ip to nginx server"
openstack server add floating ip "$nginxName" "$nginxIP"


echo "Adding known hosts"
#Add to known hosts
until nc -z -v $nginxIP 22 ; do
  echo "Server is still building.. retrying in 10 seconds"
  sleep 10
done
#Add host when netcat successfully scan port 22
ssh-keyscan -H "$nginxIP" >> ~/.ssh/known_hosts

sleep 5
#Copy key to server
scp /mounted/.ssh/am223yd-1dv031_key_ssh.pem ubuntu@"$nginxIP":

echo "Configuring ssh key on nginx server"

ssh ubuntu@"$nginxIP" /bin/bash << HERE
  sudo apt-get update && sudo apt-get -y upgrade && sudo apt-get install -y nginx
  mv am223yd-1dv031_key_ssh.pem ~/.ssh/id_rsa
  sudo chmod 600 ~/.ssh/id_rsa
  eval $(ssh-agent -s)
  sleep 2
  ssh-add ~/.ssh/id_rsa
HERE

ssh-keyscan -H "$nginxIP" >> ~/.ssh/known_hosts

#Get local addresses for the node.js servers
nodeIp1=$(openstack server show -f value -c addresses "$name1" | sed 's/^[^=]*=//g')
nodeIp2=$(openstack server show -f value -c addresses "$name2" | sed 's/^[^=]*=//g')

bash /mounted/scripts/nginx_add_files.sh "$nginxIP" "$nodeIp1" "$nodeIp2"

# Install and configure node servers

echo "Installing node.js servers"
# Copy script and files to nginx server and run the installer there
scp /mounted/scripts/node_install.sh ubuntu@"$nginxIP":
scp /mounted/node/app.js ubuntu@"$nginxIP":
ssh ubuntu@"$nginxIP" /bin/bash << HERE
  bash node_install.sh "$nodeIp1"
  bash node_install.sh "$nodeIp2"
  rm app.js
  rm node_install.sh
HERE
