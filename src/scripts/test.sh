#!/bin/bash
#server_vars="/mounted/server_vars.json"
#bash /mounted/scripts/test2.sh "$server_vars"


#i=0
#until [ "$i" == 4 ]; do
#  echo $i
#  ((i=i+1))
#done
#i=0
#echo $i

test="hejhopp"

test2=$"lala $test"

bash /mounted/scripts/test2.sh "$test2"