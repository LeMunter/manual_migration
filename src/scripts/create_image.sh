#!/bin/bash

sudo docker build -t testis mounted/svc/test
id=$(sudo docker images | sed '1d' | awk 'NR==1{print $3}')
echo "$id"