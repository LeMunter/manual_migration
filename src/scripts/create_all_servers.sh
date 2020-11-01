#!/bin/bash
server_vars="/mounted/server_vars.json"

bash /mounted/scripts/create_gw.sh "$server_vars" &&
bash /mounted/scripts/create_nfs.sh "$server_vars" &&
bash /mounted/scripts/create_registry.sh "$server_vars"