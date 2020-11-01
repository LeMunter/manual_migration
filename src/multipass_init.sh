sudo apt-get update && sudo apt upgrade -y
sudo apt-get install -y net-tools
sudo apt install -y python3-pip python3-dev
sudo pip3 install --upgrade pip
sudo pip3 install python-openstackclient
sudo apt-get install -qq apt-transport-https ca-certificates curl software-properties-common jq
source /keys/am223yd-1dv032-ht20-openrc.sh
# Add key to vm
cp /keys/secrets/test.pem ~/.ssh/id_rsa
sudo chmod 600 ~/.ssh/id_rsa
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa