#!/bin/bash

# Uppdatera alla paket
apt update
apt upgrade -y

echo "hejsteffe"
# Installera paket som är nödvändiga eller bra att ha
apt install -qq apt-transport-https ca-certificates curl software-properties-common jq
apt install jq