terraform {
  required_version = ">= 1.0.0"

  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      # UPGRADE THIS: Change rc4 to rc6
      # version = "3.0.1-rc6" 
      version = "3.0.2-rc04" # This version fixes the VM.Monitor bug

    }
    # ... rest of providers ...
  }
}


provider "proxmox" {
  pm_api_url      = var.proxmox_api_url
  pm_user         = var.pm_user
  pm_password     = var.pm_password
  pm_tls_insecure = true
  
  # Keep these for troubleshooting
  pm_parallel     = 1
  pm_timeout      = 600
  pm_log_enable   = true
  pm_log_file     = "terraform-plugin-proxmox.log"

# THIS IS THE KEY: It bypasses the hard-coded VM.Monitor check
#  pm_minimum_permission_check = false
}



provider "kubernetes" {
  config_path = "~/.kube/config-sentinel"
}



  provider "helm" {
    # Add the "=" sign here to turn the block into an argument
    kubernetes = {
      config_path = "~/.kube/config-sentinel"
    }
  }

