#!/bin/bash
sudo apt-get update && sudo apt upgrade -y
sudo apt-get install -y net-tools
sudo apt install -y python3-pip python3-dev
sudo pip3 install --upgrade pip
sudo pip3 install python-openstackclient
sudo apt-get install -qq apt-transport-https ca-certificates curl software-properties-common jq
pip install python-octaviaclient
snap install yq
sudo apt-get install -y python-sponge

bash /mounted/pw_change.sh
for f in /keys/*.sh; do
  source $f -H
done
# Add key to vm
cp /keys/key.pem ~/.ssh/id_rsa
sudo chmod 600 ~/.ssh/id_rsa
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa
ssh-keygen -y -f ~/.ssh/id_rsa > ~/.ssh/id_rsa.pub
bash /mounted/scripts/run.sh