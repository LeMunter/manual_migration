#!/bin/bash

gwIP="$1"
fixedIp="$2"

until ssh "$gwIP" nc -z -v "$fixedIp" 22 ;
  do
  echo "Server is still building.. retrying in 10 seconds"
  sleep 10
done