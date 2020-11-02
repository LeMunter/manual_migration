#!/bin/bash
server_vars="/mounted/server_vars.json"

hostIP=$(jq -r '.[] | select(."name" == "gw") | ."float_ip"' "$server_vars")
remoteIP=$(jq -r '.[] | select(."name" == "master") | ."ip"' "$server_vars")
dr=$(jq -r '.[] | select(."name" == "dr") | ."ip"' "$server_vars")

test="hej"

ssh -J "$hostIP" "$remoteIP" /bin/bash << HERE
    #sudo docker build "$HOME"/svc/mariadb --tag "$dr":5000/
    echo "$dr":5000
HERE
