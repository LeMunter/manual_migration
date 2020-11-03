### Prerequisites
* Hyper-v 
* openstack account  
# Start
Start by creating a folder with the name "secrets" somewhere on your computer. 
Download your personal RC file from openstack and place it in that folder. 
Open the RC file with any simple text editor. 
Enter your openstack password on line 34. 
The line should now look like this,” export OS_PASSWORD=$<your-password-here>”.
Also place your private ssh-key-file inside this folder and name it “key.pem”.

Now you are ready to start your multipass virtual machine.
Download [multipass](https://multipass.run/) and install it with the default settings
(must have hyper-v enabled).

Start your multipass instance by running these commands.
   
    multipass launch --name vm   
    multipass mount <path-to-"src"-directory> vm:/mounted/
    multipass mount <path-to-secrets-directory> vm:/keys
    multipass shell vm
    bash /mounted/multipass_init.sh

Wait for the script to finish.
With everything installed you simply run the command

    bash /mounted/scripts/run.sh

The script takes a while to complete so just be patient.

1. When the script has completed, save the ip-address and port number printed at the end.
2. Go to your openstack project. Go to ---> "Network" --> "Load Balancer" and click on "Create Load Balancer".
    * Provide a name and choose the subnet "kub_subnetwork" and click next.
    * Choose the protocol "HTTP" and with port 80 and click next.
    * Choose "ROUND_ROBIN" and click next.
    * Add the instances node-1,node-2,node-3 and give them all the port saved earlier and click next.
    * Choose the monitor type HTTP and click Create Load Balancer.
3. Click on the dropdown menu on the "Actions" section for the load balancer and click Associate Floating IP. 
    * Choose the IP from step 1. 
9. Click on the name of the load balancer and from there click on the ID under "Port ID".
10. Click "Edit Port" and go to the Security Groups tab. 
    * Click the "+" symbol on the HTTP security group and click update.

Everything should now be up and running, and you should be able to access the page with the IP address from before. 
 

## Script Walkthrough

#### Gateway
    
#### Docker registry
    
#### Storage

#### Master 

#### Nodes

    