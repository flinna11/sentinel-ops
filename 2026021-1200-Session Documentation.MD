Session Documentation: Proxmox Terraform Authorization Troubleshooting

This session focused on resolving a persistent authorization error encountered while using the telmate/proxmox Terraform provider. Despite valid credentials, the provider was unable to perform the initial environment scan.
The Core Issue

Error: user terraform-prov@pve has valid credentials but cannot retrieve user list, check privilege separation of api token

This error occurs because the Terraform provider attempts to call the /access/users endpoint upon initialization. Even with high-level roles (like PVEAdmin), the API token is often restricted by Proxmox's security scoping.
Troubleshooting Steps Taken
Step	Action	Logic
1	Verified provider.tf	Confirmed no duplicate provider blocks or syntax errors.
2	Disabled Privilege Separation	Unchecked the "Privilege Separation" box in the API Token settings to allow the token to "see" beyond itself.
3	Assigned Root Permissions	Used pveum acl modify / -token ... -role Administrator to ensure the token has explicit rights at the Datacenter root (/).
4	API Service Reset	Attempted systemctl restart pveproxy to clear cached ACLs, which resulted in a service hang and subsequent hardware power cycle.
5	Conflict Resolution	Identified and removed a duplicate token name (terraform-token) belonging to root@pam to prevent identity confusion.
Current Status

    Infrastructure: Proxmox host has been power-cycled and services are online.

    Permissions: API Token terraform-prov@pve!terraform-token is configured with Privilege Separation: OFF and Role: Administrator on Path: /.

    Terraform: Local environment has been cleaned (rm -rf .terraform/).

Future Actions & Final Recovery Plan

Should the error persist after the reboot, follow these actions in order:
1. Generate a "Clean Break" Identity

Avoid reusing the name terraform-token. Create a completely new token to bypass any lingering API cache issues.

    New Token ID: prov-deploy-2026

    Settings: Ensure Privilege Separation is unchecked during creation.

    ACL: Apply the permission via CLI to ensure it hits the backend:
    Bash

    pveum acl modify / -token 'terraform-prov@pve!prov-deploy-2026' -role Administrator

2. Update and Re-Initialize

Update provider.tf with the brand new Secret UUID and Token ID, then run:
Bash

terraform init -upgrade
terraform plan

3. Network and Hardware Audit

If the "User List" error remains, verify:

    Firewalls: Ensure no local firewall (ufw/iptables) is intercepting API calls to port 8006.

    Disk Space: Check df -h on Proxmox; a full root partition can cause the API to return 403/Forbidden errors because it cannot write temporary session files.

Would you like me to generate a clean, final version of the provider.tf and main.tf based on these new token names?
