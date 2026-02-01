# Sentinel-Ops: Proxmox Infrastructure as Code

This repository manages my automated home lab environment using **Terraform** and **Proxmox VE**.

## 🚀 Project Overview
- **Provider**: Telmate/Proxmox (v3.0.2-rc07)
- **Primary Resource**: Ubuntu Server VM (VM-106)
- **Automation**: GitHub Actions (Terraform Planning)

## 🛠️ Hardware Specs
- **Host**: Proxmox VE 9 | 16GB Physical RAM | 7.8GB Swap
- **Target VM**: 2GB RAM | QEMU Guest Agent Enabled

## 🔐 Security
- Sensitive credentials are managed via `secret.tfvars` (local) and **GitHub Secrets** (CI/CD).
- Hardcoded secrets are strictly prohibited and blocked by GitHub Push Protection.

## 📖 Usage
To deploy or update infrastructure locally:
1. `terraform init`
2. `terraform plan -var-file="secret.tfvars"`
3. `terraform apply -var-file="secret.tfvars"`
