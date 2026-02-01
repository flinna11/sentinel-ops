terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.1-rc6" # Stable release candidate for modern Proxmox
    }
  }
}

provider "proxmox" {
  pm_api_url          = "https://192.168.1.104:8006/api2/json" # Your Proxmox Host IP
  pm_api_token_id     = "terraform-prov@pve!terraform-token"
  pm_api_token_secret = "96203c4e-8a71-4608-bb74-22f82085d623"
  pm_tls_insecure     = true
}

