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

variable "proxmox_api_url" {
  type = string
}

variable "pm_user" {
  type = string
}

variable "pm_password" {
  type      = string
  sensitive = true
}
