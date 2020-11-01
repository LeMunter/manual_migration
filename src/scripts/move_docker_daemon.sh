#!/bin/bash
hostIP="$1"
remoteIP="$2"

scp -oProxyJump="$hostIP" /mounted/servers/master/daemon.json "$remoteIP":
ssh -J "$hostIP" "$remoteIP" sudo mv daemon.json /etc/docker/
ssh -J "$hostIP" "$remoteIP" sudo systemctl restart docker