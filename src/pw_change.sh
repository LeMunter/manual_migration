#!/bin/bash
echo ""
echo "-------------Please provide openstack password-------------"
read -sr PASSWORD

file=$(find /keys -regex ".*\.\(sh\)")
echo "$file"
mv "$file" /tmp/rcfile
#vim "$file" -c s/"read -sr OS_PASSWORD_INPUT"/test/g
sed -i 's/echo "Please enter your OpenStack Password for project $OS_PROJECT_NAME as user $OS_USERNAME: "//1' /tmp/rcfile
sed -i 's/read -sr OS_PASSWORD_INPUT/OS_PASSWORD_INPUT="'"$PASSWORD"'"/1' /tmp/rcfile
mv /tmp/rcfile "$file"
