# This file now only manages the "Physical" (Virtual) Hardware
resource "proxmox_vm_qemu" "kubernetes_node" {
  name        = "ubuntu24" # Match the name from your 'kubectl get nodes'
  target_node = "pve"      # The name of your node in Proxmox
  vmid        = 100        # Your VM ID
  
  # Operating System / Template
  clone = "ubuntu-24-template" # Or whatever template you used

  # Hardware Specs for RabbitMQ (Needs a bit of beef for 3 nodes)
  cores   = 4
  memory  = 4096
  agent   = 1

  network {
    model  = "virtio"
    bridge = "vmbr0"
  }


disk {
    slot    = "scsi0"      # This replaces 'slot = 0'
    size    = "40G"
    type    = "disk"       # This replaces 'type = scsi'
    storage = "local-lvm"
  }


  #disk {
  #  slot    = 0           # Add this line
  #  size    = "40G"
  #  type    = "scsi"
  #  storage = "local-lvm"
  # }


}
