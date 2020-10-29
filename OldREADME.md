# am223yd-examination 1
[Network Analysis](NetworkAnalysis.pdf)

# am223yd-examination 2

#Introduction
My aim was to create as much of the server creation as possible through automated scripts. However, some extra features, such as HTTPS support and Livepatch, are kept manual but are included in a step-by-step guide. 
This step-by-step guide will provide all the steps I took creating my network.
The topology of the complete network can be found here [Topology](/Ex2/topology.jpg)

### Preparation
* Start by creating a router using the openstack interface.
* Create a LAN network and connect it to the router.
* Create a security group for the webserver and open up TCP traffic on ports 22(ssh), 443(https) and 3306(mysql).
* Create a security group for the dns servers and open up TCP traffic on ports 22(ssh), 53(dns) and UDP traffic on port 53 as well.
* Create a security group for the load balancer and open up TCP traffic on ports 22(ssh), 443(https) and 80(http).
* Create a security group for the node.js servers and open up TCP traffic on ports 22(ssh), 3000(nginx).
* Open the script file "ws_server_create.sh" and provide the id of the webserver security group created before and change the float ip to your own.
* Open the script file "dns_server_create.sh" and provide the id of the dns security group created before and change the float ips to your own.
* Open the script file "node_create.sh" and provide the id of the node.js and load-balance security groups created before and change the float ip to your own.
* Download and install Multipass - https://multipass.run/
* Open up git bash and create a ubuntu virtual machine by running "multipass launch --<name of instance>"
* Mount the "shared" directory by running "multipass mount "path-to-folder <name of instance>:/mounted".
The shared folder containing the scripts and config files is now mounted and acceptable in the virtual machine in the folder "mounted".
* Open the shell of the created VM and update and install the necessary software on the machine with the commands:


      sudo apt-get update && sudo apt-get dist-upgrade
      sudo apt-get install -y net-tools
      sudo apt-get install -y expect 
      sudo apt install -y python3-pip python3-dev
      sudo pip3 install --upgrade pip
      sudo pip3 install python-openstackclient
* Copy the ssh key and add it to the VM (key not included):
	
	
	  cp /mounted/.ssh/nameOfKey ~/.ssh/id_rsa
	  sudo chmod 600 ~/.ssh/id_rsa
	  eval $(ssh-agent -s)
	  ssh-add ~/.ssh/id_rsa
* Add authorization for the previously installed openstack client:
        
      source /mounted/am223yd-1dv031-vt20-openrc.sh
        -enter openstack password
* Reboot the Vm with sudo reboot

Now the VM should be ready to start creating the servers. 
#Step-by-step guide
#### ----Creating Apache webserver----
* Run the script:


      bash /mounted/scripts/ws_server_create.sh
* Enter some user credentials for your wordpress database user when prompted to.
* Wait for the script to finish.
* Connect to the created server.


      ssh ubuntu@<ip-address>
* Install livepatch for automatic kernel updates
    * Go to https://ubuntu.com/livepatch
    ->"Get livepatch"->"Ubuntu user"->"Get your livepatch token"(Need to have or register a ubuntu one account")
    
    
      sudo snap install canonical-livepatch
      sudo canonical-livepatch enable <key provided by the link above>
* Check that livepatch is working


      sudo canonical-livepatch status
* Install HTTPS certificate using certbot


      sudo snap install --beta --classic certbot
      sudo certbot --apache -d acmea.am223yd-1dv031.devopslab.xyz
      sudo systemctl restart apache2
    
The Apache server should now be created
#### ----Creating DNS servers----
* Run the script:


      bash /mounted/scripts/dns_server_create.sh
* Wait for script to finish
* Connect to the master server to check if it was installed correctly


      ssh ubuntu@<ip-address>
      sudo named-checkconf
      sudo named-checkzone am223yd-1dv031.devopslab.xyz /etc/bind/zones/db.am223yd-1dv031.devopslab.xyz
* Add the following the "hosts" file on the master


      sudo nano /etc/hosts
      "<master-local-ip> ns1.am223yd-1dv031.devopslab.xyz ns1"
* Exit the master server and connect to the slave server.


      ubuntu@<ip-address>
      sudo named-checkconf
* Add the following the "hosts" file on the slave


      sudo nano /etc/hosts
      "<slave-local-ip> ns2.am223yd-1dv031.devopslab.xyz ns2"

The DNS server should now be set up and ready.
Go to "acmea.am223yd-1dv031.devopslab.xyz" to test

#### ------Create node.js servers including a nginx load balancer------
* Run the script:


      bash /mounted/scripts/node_create.sh
* Wait for script to finish
* Connect to the nginx server and Install HTTPS certificate using certbot


      ssh ubuntu@<ip-address>
      sudo snap install --beta --classic certbot
      sudo certbot --nginx -d acmeb.am223yd-1dv031.devopslab.xyz
      sudo nginx -s reload

The node.js servers should now be installed and balanced with the nginx server.
Test by going to "acmeb.am223yd-1dv031.devopslab.xyz".

# Script Walkthrough

My aim with the scripts was both to make it easy to create the servers, and to create the means for maintaining them. Therefore, I created separated the scripts for creating and updating the files for each server. This makes it easy to update the config files on your own computer and replacing them with the files on the server. 

## Apache
I started by doing the scripts for the apache server. The biggest problem in the beginning was figuring out how to wait for the server to be ready to connect. I just used a fixed sleep-time of 60 seconds at first to get around that problem. After some research I discovered I can scan the port ssh uses to confirm when ssh is up and listening. With this problem fixed, I could then assign the float IP I had reserved for the server and start configuring it. I started by updating the ubuntu system and installing apache2, php, mariadb and mysql. I preceded to open up the uncomplicated firewall on the system to allow traffic for apache and openssh. I then created the directories specified as the rootfolder for my wordpress site and set the appropriate permissions for the folders. As my plan was to separate the server creation from the copying of files, I created a new script and called for it in my main script. In this script I copy the config-file from my virtual machine to the server, moving it to the right place and enabling it in apache2.


With apache now ready I moved on to install the database for the wordpress site. I use a series of prompts where the user enters the information for the creation the wordpress database and an admin-user for that database.
With the information saved I start by removing root access to the database when not on local host, removing anonymous users and deleting the test-database created when installing mysql. This tightens up security by only allowing access for a local root and the database admin. Then I created the new database and user and give it the appropriate privileges.
Next I move on to installing wordpress itself. I use the wget command to download the latest wordpress and decompress the downloaded tar file to a temporary folder. From there, I create a new config-file from the included sample-config and move the contents into the root directory before giving apache access to it using chown. Here I needed to generate salts and update my wp-config with them. My first attempt was successful, although a bit awkward. So, I decided to use a readymade script which I found [here](https://github.com/ahmadawais/WP-Salts-Update-CLI/blob/master/wpsucli.sh) to update the salts in the config. Now it was only the matter of updating the config with the information for the database from earlier and everything was done. 
## DNS servers
Now it was time to create the DNS servers. I used the same structure as before, but for two servers simultaneously. When both servers are created, I install bind9 on both machines and start copying the appropriate config-files to the master and the slave server. With all files copied, I connect to the servers and move the files to the right location and restart bind9. Both nameservers should now be functional and containing a-records for both the apache server and the nginx server soon to be created.


## Node.js & Nginx
The nginx server creation works the same way as before, now with three servers created simultaneously and with the addition of the copying the ssh key to the server and adding this identity. This is necessary because the nginx server is going to be used as a jumping machine to connect to the node.js servers. With this done the configuring of the nginx server can start. I add the local addresses of the created node.js servers to the config file used by nginx to connect to the node.js server. Then I move both config-files to the nginx server and set the appropriate permissions. Now it is time to configure the node.js servers. This is done by first copying the files to the nginx server. Then connecting to the nginx server and from there copy the files to both node.js servers. Then I can connect to both node servers and install node.js and process manager 2 which I then use to initialize my node.js application. Now nginx should load balance between the two node.js servers automatically. 
Everything should now be up and running and can be tested by going to 

•	https://acmea.am223yd-1dv031.devopslab.xyz/  - Apache server

•	https://acmeb.am223yd-1dv031.devopslab.xyz/  - Node.js servers

#### Extra features
I decided to implement HTTPS which tightens security by using encrypted communication.
I also added the Livepatch feature to the apache server which enables it to update automatically without the need to reboot the system.
