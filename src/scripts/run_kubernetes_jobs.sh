#!/bin/bash

server_vars="/mounted/server_vars.json"
os_vars="/mounted/os_vars.json"

gwIP=$(jq -r '.[] | select(."name" == "gw") | ."float_ip"' "$server_vars")
master_IP=$(jq -r '.[] | select(."name" == "master") | ."ip"' "$server_vars")

bash /mounted/scripts/move_files.sh
ssh -J $gwIP $master_IP bash svc/apply_jobs.sh