Component,VM ID,IP Address,Role,Status
Control Center,100,192.168.1.50,OOBM / Management,Active
K8s Master,200,192.168.1.141,RKE2 Control Plane,Active
K8s Worker 0,201,192.168.1.139,Workload Node,Booted (Pending Join)
K8s Worker 1,202,192.168.1.209,Workload Node,Booted (Pending Join)'


That is a huge milestone! Having all three nodes reachable and booting from their disks means the "infrastructure" phase is officially done. Now we just need to "glue" them together into a Kubernetes cluster so they can start hosting your RabbitMQ setup.

Since VM 200 (Master) is already running the rke2-server, we just need to point the two workers at it.

1. Configure the Workers (VM 201 & VM 202)
You need to do this on both worker nodes. SSH into each one and perform these steps:

A. Create the config directory:

Bash

sudo mkdir -p /etc/rancher/rke2/
B. Create the configuration file:

Bash

sudo nano /etc/rancher/rke2/config.yaml
C. Paste the following (Update with your specific details):

YAML

server: https://192.168.1.141:9345
token: <PASTE_YOUR_TOKEN_FROM_VM_200_HERE>
Note: Make sure you use the token you got from sudo cat /var/lib/rancher/rke2/server/node-token on the Master earlier.

D. Install and Start the Agent:

Bash

# Install as an agent
curl -sfL https://get.rke2.io | sudo INSTALL_RKE2_TYPE="agent" sh -

# Enable and start
sudo systemctl enable --now rke2-agent.service
2. Verify the Cluster from VM 100 (OOBM)
You don't want to keep logging into the Master to check things. Let's make your VM 100 the command center.

Install kubectl on VM 100:

Bash

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
Copy the config from the Master:

Bash

mkdir -p ~/.kube
# Run this from VM 100 (it pulls the config from your Master)
scp andy@192.168.1.141:/etc/rancher/rke2/rke2.yaml ~/.kube/config

# Update the IP inside the config (it defaults to 127.0.0.1)
sed -i 's/127.0.0.1/192.168.1.141/g' ~/.kube/config
3. The Final Test
From your VM 100 terminal, run:

Bash

kubectl get nodes
What you want to see:

vm200 -> Ready, Control-plane

vm201 -> Ready

vm202 -> Ready

Do all three nodes show up as "Ready," or is one of them still "NotReady" while it pulls down the networking plugins? Once they are all green, we are ready to deploy RabbitMQ!


Sentinel-Ops Progress ReportCurrent Status: Infrastructure ReadyOOBM Box (VM 100): Fully functional as the management workstation.K8s Master (VM 200): * Boot loop resolved (Disk attached & Boot order fixed).RKE2 Server installed and running at 192.168.1.141.Cluster Token generated and accessible.K8s Workers (VM 201 & 202):Hardware issues resolved (Disks attached).OS is bootable and reachable via SSH.Ready for RKE2 Agent configuration.🗂️ Project Index (The Lab Map)ComponentVM IDIP AddressRoleStatusControl Center100192.168.1.50OOBM / ManagementActiveK8s Master200192.168.1.141RKE2 Control PlaneActiveK8s Worker 0201192.168.1.139Workload NodeBooted (Pending Join)K8s Worker 1202192.168.1.209Workload NodeBooted (Pending Join)🗺️ Roadmap to RabbitMQ Cluster

Phase 1: Cluster Unification (Next Steps)Join Worker 201: Apply the config.yaml using the Master's token and start rke2-agent.Join Worker 202: Repeat the process for the second worker.kubectl Configuration: Link VM 100 to the cluster so you can manage it without SSH-ing into the nodes.
Phase 2: Storage & NetworkingInstall Longhorn or Local Path Provisioner: Kubernetes needs a way to manage disks for RabbitMQ.Install Metallb (Optional): To give your RabbitMQ cluster a dedicated "Load Balancer" IP on your home network.
Phase 3: RabbitMQ DeploymentInstall Helm: The package manager for Kubernetes.Deploy RabbitMQ Cluster Operator: This ensures the 3-node RabbitMQ cluster is "self-healing."Deploy the Cluster: Create the actual RabbitMQ instances across your two workers for high availability.📝 Important "Golden" Info for Next SessionMaster IP: 192.168.1.141SSH Workaround: Remember you may still need the -o KexAlgorithms=+diffie-hellman-group1-sha1 flag until you finish the SSH modernization on the workers.Join Token Location: sudo cat /var/lib/rancher/rke2/server/node-token (on VM 200).

When you're ready to pick back up, would you like to start by joining the workers or setting up kubectl on your management box?
