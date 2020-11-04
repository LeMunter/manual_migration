### Prerequisites
* Hyper-v 
* openstack account  
# Start
Start by creating a folder with the name "secrets" somewhere on your computer. 
Download your personal RC file from openstack and place it in that folder. 
Also place your private ssh-key-file inside this folder and name it “key.pem”.

Now you are ready to start your multipass virtual machine.
Download [multipass](https://multipass.run/) and install it with the default settings
(must have hyper-v enabled).

Start your multipass instance by running these commands in a terminal.
   
    multipass launch --name vm   
    multipass mount <path-to-"src"-directory> vm:/mounted/
    multipass mount <path-to-secrets-directory> vm:/keys
    multipass shell vm
    
When in the vm shell, simply run this command to create all servers.
    
    bash /mounted/multipass_init.sh

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
 

## Walkthrough

### Network
The first thing that happens in the script is the creation of the network, subnetwork and all the miscellaneous services needed later. These include the security groups for SSH (port22),HTTP (port 80) and two floating IPs. The names of all services and IP addresses are saved in a  json file called os_vars.json.


#### Gateway
Now it is time to create the gateway server, this server will be used as a jumping machine for the other servers inside the local network. As the gateway server will need to communicate with the outside, one of the floating IPs created earlier will be assigned to this server, as well as the SSH security group. Also a cloud-init file will be provided for the server creation to update and install some basic tools. After the server is created successfully, all necessary information about the server is saved in a json file called server_vars.json

#### Storage
As permanent storage is needed for this project, and Kubernetes pod lifecycles are rather short-lived, storage will be handled using NFS (network file system). A NFS server storing the data will be created and shared directories will be mounted to all the pods.

The NFS server is created similarly to the gateway, the big difference being the cloud-init file. This time the init file installs the nfs-kernel, creates the folders to be shared, sets the necessary permissions for the folders,  and updates the “exports” file to allow traffic to the shared directories. 
As always, the information about the server is saved to server_vars.json
#### Docker registry
Some docker images will be created later on. These will be saved in a private registry server. To accommodate this, the init file will install docker, create a daemon.json config-file and start a stateless registry service with the port 5000.
#### Master 
Next in line is the master server controlling all the Kubernetes nodes. This server is the main Kubernetes server handling all Kubernetes objects. Kubernetes, docker and nfs-common is installed to the server using the cloud-config. The master server also needs to communicate with the private docker registry to be able to push images. As stated earlier we need to add the registry IP to an insecure registry in the daemon.json file to be able to communicate, this file is updated automatically when the registry is created and later copied to the master server.
#### Nodes
With the master server in place, the nodes are next in line. The three nodes are created very similar to the master server. They all install docker, Kubernetes and nfs-common using the cloud-init file. They also need to add the insecure registry line to the daemon.json file as they need to pull the images from the registry.

With all the servers created, the daemon.json files with the included registry IP are copied to all nodes and master servers.
#### Kubernetes
With all the servers created, its now time to setup the Kubernetes cluster. This starts with running the kubeadm init command on the master server. When the cluster is created, we deploy a calico object organizing the cluster-network. The init command also provides a join-command to add nodes to the cluster. This command automatically runs on all nodes which joins them to the cluster.
Now all necessary files for our deployments are moved to the master server. The docker images are built using the Dockerfiles and pushed to the registry. When all images are created, all yaml config files are applied using the kubectl command. This deploys all objects necessary for the project.
With this done everything should now work inside the local network.
#### Load Balancer
The last step is the load balancer which balances the traffic among three proxy-servers using round robin. Theses proxy-servers have a nodeport service connected, enabling them to communicate outside the cluster. These proxy-servers in turn distributes the traffic to the websvc- pods using local dns addresses.  This dual-layer balancing creates redundancy and a great amount of spread of traffic.
#### Reflections
My goal with this project was to challenge myself and create scripts automating the entire project. I think I achieved this for the most part. The one thing missing is the automated creation of the load balancer. This is because I could not get the extension Octavia for openstack to work for some reason. Other than that, everything is automated and some of the scripts included make the effort of updating the Kubernetes object a breeze. I have also learned a great deal about shell scripting (enough for me to really appreciate the greatness of ansible), and kubernetes along the process.