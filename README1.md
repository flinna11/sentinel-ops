# 🛡️ Sentinel Node (Ubuntu 24.04 / RKE2)

## 📊 System Overview
- **Hostname:** ubuntu24 (andy-Standard-PC-i440FX)
- **IP Address:** 192.168.1.50
- **Resources:** 24GB RAM | VirtIO-GPU
- **Role:** Master Node / IaC Controller

## 📂 Repository Structure (IaC)
- `/playbooks`: Ansible/Automation logic transferred from Windows.
- `active-netplan.yaml`: Current L2/L3 networking config.
- `rke2-config.yaml`: Kubernetes cluster parameters.
- `gdm-display-fix.conf`: Proxmox console scaling configuration.

## 🔄 Standard Operating Procedure (SOP)
### To Update Configurations from VM:
1. Modify the file in `~/sentinel-ops`.
2. `git add <filename>`
3. `git commit -m "Description of change"`
4. `git push`

### To Sync Windows Playbooks:
1. Drag/Drop to GitHub Web UI.
2. On VM: `git pull origin main`.
