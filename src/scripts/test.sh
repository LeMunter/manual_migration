#!/bin/bash

nfs_ip=$(jq '.[1].ip' /mounted/server_vars.json | tr -d '"')
nfs_port=5000
# shellcheck disable=SC2046 disable=SC2094
cat <<< $(jq '."insecure-registries"[0] ="'"$nfs_ip"':'"$nfs_port"'"' /mounted/servers/nodes/daemon.json) > /mounted/servers/nodes/daemon.json