# 1. THE RESOURCE BLOCK
# This defines what you are building (a QEMU VM) and gives it a local name ("web_server")
resource "proxmox_vm_qemu" "web_server" {

  # 2. GENERAL SETTINGS
  vmid        = 106      # Optional: new ID (106)
  name        = "VM-106" # The name that appears in Proxmox
  target_node = "pve"    # Your Proxmox hostname
  description = "Provisioned via Terraform"

  # 3. CLONE SETTINGS
  # This MUST match the name of the template you found earlier
  clone      = "VM 105"
  full_clone = true # 'true' for a standalone copy, 'false' for linked

  # 4. HARDWARE CONFIGURATION
  # Move cores/sockets inside this block
  cpu {
    cores   = 2
    sockets = 1
    type    = "host"
  }
  memory = 2048
  agent   = 1 # Enable QEMU Guest Agent

  # 5. DISK & STORAGE
  # Ubuntu 24.04 works best with virtio-scsi

   # We use the nested 'disks' block for modern Telmate syntax
  disks {
    scsi {
      scsi0 {
        disk {
          size      = "20G"
          storage   = "local-lvm"
          replicate = false
        }
      }
    }
  }


  # 6. NETWORK CONFIGURATION
  network {
    id = 0
    model  = "virtio"
    bridge = "vmbr0"
  }

  # 7. CLOUD-INIT (Automation)
  # This is how Terraform configures the OS without you logging in
  os_type   = "cloud-init"
  ipconfig0 = "ip=192.168.1.104/24,gw=192.168.1.1"

  # Paste your actual SSH public key here
  sshkeys = <<EOF
    ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK3JZUpG7qCJqDSjSJG2VGdZ7w5dd11YFNpsWXV9LkTb andy@ubuntu24
    EOF
}
