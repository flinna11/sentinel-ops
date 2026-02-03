# This file now only manages the "Physical" (Virtual) Hardware
# Control Plane (Master)
resource "proxmox_vm_qemu" "k8s_master" {
  name        = "k8s-master"
  target_node = "pve"
  vmid        = 200
  tags        = "k8s;master;sentinel-ops" # Tagged as requested
  
  # Recommended specs for Control Plane
  cores   = 2
  memory  = 4096
  agent   = 1
  
  # Cloning from your goldimage template
  clone = "VM 105" 

  network {
    id     = 0        # Add this line
    model  = "virtio"
    bridge = "vmbr0"
  }
}

# Worker Nodes
resource "proxmox_vm_qemu" "k8s_worker" {
  count       = 2 # VM 106 + one additional worker
  name        = "k8s-worker-${count.index + 1}"
  target_node = "pve"
  vmid        = 201 + count.index
  tags        = "k8s;worker;sentinel-ops" # Tagged as requested
  
  # Recommended specs for Workers
  cores   = 2
  memory  = 4096
  agent   = 1
  
  clone = "VM 105"

  network {
    id     = 0        # Add this line    
    model  = "virtio"
    bridge = "vmbr0"
  }
}
