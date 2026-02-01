variable "proxmox_token_id" {
  description = "API Token ID for Proxmox"
  type        = string
  sensitive   = true
}

variable "proxmox_token_secret" {
  description = "API Token Secret for Proxmox"
  type        = string
  sensitive   = true
}

