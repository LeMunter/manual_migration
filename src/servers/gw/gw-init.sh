#!/bin/bash

# Uppdatera alla paket
apt update
apt upgrade -y

# Installera paket som är nödvändiga eller bra att ha
apt-get install -qq apt-transport-https ca-certificates curl software-properties-common jq tmux net-tools
