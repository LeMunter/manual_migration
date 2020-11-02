#!/bin/bash

server_vars="/mounted/server_vars.json"
os_vars="/mounted/os_vars.json"

source /keys/am223yd-1dv032-ht20-openrc.sh

bash /mounted/scripts/create_network.sh

bash /mounted/scripts/create_all_servers.sh