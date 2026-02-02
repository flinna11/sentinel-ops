terraform {
  required_version = ">= 1.0.0"

  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.1-rc4" 
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
  }
}

provider "proxmox" {
  pm_api_url          = var.proxmox_api_url
  pm_api_token_id     = var.proxmox_token_id
  pm_api_token_secret = var.proxmox_token_secret
  pm_tls_insecure     = true
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

