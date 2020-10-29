#!/bin/bash
nodeIp="$1"
echo "installing $nodeIp"
eval "$(ssh-agent -s)"
ssh-keyscan -H "$nodeIp" >> ~/.ssh/known_hosts
scp app.js ubuntu@"$nodeIp":

ssh ubuntu@"$nodeIp" /bin/bash << HERE
  curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
  sudo apt-get install -y nodejs
  sudo npm init -y
  sudo npm install express --save
  sudo npm install pm2 -g
  sudo pm2 start app.js
  exit
HERE