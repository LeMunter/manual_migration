#!/bin/bash

# Uppdatera alla paket
apt update
apt upgrade -y

# Installera paket som är nödvändiga eller bra att ha
apt-get install -qq apt-transport-https ca-certificates curl software-properties-common

# Hämta och lägg till nycklar för docker och k8s
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

# Lägg till docker och k8s repos och uppdatera
add-apt-repository -yu "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
add-apt-repository -yu "deb https://apt.kubernetes.io/ kubernetes-xenial main"

# Installera nödvändiga paket
apt-get install -qq docker-ce kubelet kubeadm kubectl nfs-common

sudo mkdir -p /etc/systemd/system/docker.service.d

# Starta om och autostata docker
systemctl daemon-reload
systemctl restart docker
systemctl enable docker
