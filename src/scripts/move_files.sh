#!/bin/bash

server_vars="/mounted/server_vars.json"
os_vars="/mounted/os_vars.json"

hostIP=$(jq -r '.[] | select(."name" == "gw") | ."float_ip"' "$server_vars")
remoteIP=$(jq -r '.[] | select(."name" == "master") | ."ip"' "$server_vars")

scp -r -oProxyJump="$hostIP" /mounted/svc "$remoteIP":
