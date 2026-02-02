terraform {
  required_version = ">= 1.0.0"

  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      # UPGRADE THIS: Change rc4 to rc6
      version = "3.0.1-rc6" 
    }
    # ... rest of providers ...
  }
}

provider "proxmox" {
  pm_api_url          = var.proxmox_api_url
  pm_api_token_id     = var.proxmox_token_id
  pm_api_token_secret = var.proxmox_token_secret
  pm_tls_insecure     = true

  # This will now be recognized because of the version bump above
  pm_minimum_permission_check = false
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

