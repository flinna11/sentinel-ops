This Technical Learning, Investigation, and Deployment Report synthesizes our expert-level discussions on architecting a high-performance, container-ready infrastructure using Proxmox VE, Ubuntu 24.04 LTS, and RKE2.

Infrastructure Report: Ubuntu 24.04, RKE2, and Advanced Containerization  
I. Index  
Initial Troubleshooting: Resolving Kernel and Installer Lock-ups.

Final Optimized VM Configuration: Performance-tuned Hardware Specs.

Gold Template Creation Workflow: Standardization and Automation.

Post-Deployment Best Practices: RKE2 Security and Networking.

Configuration Management: Git and SBoMs.

Future Roadmap: RabbitMQ, OCI, and Kata Containers.

1\. Initial Troubleshooting (Locks up)  
During the deployment of Ubuntu 24.04 (Noble Numbat) on Proxmox, we identified critical hang points related to hardware abstraction.

Display Initialization: The "Subiquity" installer often freezes on a purple screen or black console.

Fix: Change Display to virtio-gpu. Avoid default VGA/VMware drivers.

CPU Instruction Passthrough: Generic kvm64 CPUs caused kernel panics or stalls during high-load installation phases.

Fix: Set CPU Type to host to allow the VM to utilize the physical i7-4770 instruction sets (AES, AVX).

The "Refreshing Installer" Loop: A race condition where the installer attempts to update over a non-optimized virtual bridge.

Fix: Disconnect the virtual NIC during install; apply Netplan configurations post-reboot.

2\. Final Optimized VM Configuration  
To ensure "Sysadmin Peak" performance, we moved away from generic defaults to a tuned hardware stack.

Component	Setting	Performance Impact  
Processor	Type: host, NUMA enabled	Minimal latency for kernel interrupts.  
Memory	24GB (for Sentinel Node)	Sufficient overhead for RKE2 control plane \+ LLMs.  
Disk Controller	VirtIO SCSI Single	Enables IO Thread support for high IOPS.  
Storage	Async IO: io\_uring	\~20-25% improvement in NVMe/SSD throughput.  
BIOS	OVMF (UEFI) \+ EFI Disk	Required for modern Secure Boot and GPT partitions.  
QEMU Agent	Enabled	Critical for memory ballooning and clean shutdowns.

Export to Sheets

3\. Gold Template Creation Workflow  
The "Gold Template" ensures that every node in your cluster starts from a clean, secure, and identical baseline.

Sanitization: Clear /etc/machine-id and /var/lib/dbus/machine-id to avoid DHCP/IP conflicts.

Cloud-Init Integration: Add a Cloud-Init drive to Proxmox to inject SSH keys and Netplan configs dynamically.

Software Baseline: Pre-install qemu-guest-agent, curl, and socat (required for RKE2).

Conversion: Execute qm template \<vmid\> only after removing the installation ISO and setting the boot order to the virtual disk.

4\. Post-Deployment Best Practices  
Once the VM is cloned from the Gold Template and RKE2 is initialized:

Networking: Use Netplan at /etc/netplan/00-installer-config.yaml.

RKE2 Hardening: Ensure the configuration at /etc/rancher/rke2/config.yaml includes write-kubeconfig-mode: "0644".

Binary Management: Add RKE2 binaries to the path: export PATH=$PATH:/var/lib/rancher/rke2/bin

5\. Configuration Management: Git and SBoMs  
To manage infrastructure as code (IaC), we implement a versioned approach to the server's "soul."

Git-Driven Version Control:

All config.yaml, Netplan files, and Terraform manifests are stored in a Git repository. This allows for immediate recovery and tracking of changes to the 24GB RAM limits and node configurations.

Software Bill of Materials (SBoM):

Purpose: Use tools like Syft or Trivy to generate an SBoM for your Gold Template.

Audit: This provides a manifest of every library (libc, openssl) and kernel version across the fleet, allowing for vulnerability management before a container is even deployed.

6\. Future Roadmap for Investigation  
This roadmap prioritizes stability and then explores advanced isolation and messaging.

"Hello World" OCI App: Deploy a simple Nginx or Echo-server using standard OCI (Open Container Initiative) images to verify that the .50 IP correctly routes traffic.

RabbitMQ Messaging: Deploy the RabbitMQ Cluster Operator on RKE2 to handle asynchronous communication between microservices (e.g., between an AI engine and a database).

Kata Containers (Hardened Perimeter):

Goal: Investigate Kata Containers to run workloads in lightweight VMs instead of standard namespaces.

Rationale: Provides a "second layer" of isolation, crucial for multi-tenant or high-security applications within your Ubuntu 24.04 environment.

Ollama (The AI Core): Scaling Large Language Models within the 24GB memory limit.

References & Resources  
Proxmox VE Documentation

RKE2 Official Docs

Netplan Examples

Kata Containers Documentation

RabbitMQ Operator for Kubernetes

Next Step: Would you like me to generate a script that automatically mounts a Proxmox VM disk and generates an SBOM for you?

\# Install safer mounting tools  
apt update && apt install \-y libguestfs-tools

\# Install Syft (SBoM Generator)  
curl \-sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh \-s \-- \-b /usr/local/bin

\# Install Grype (CVE Scanner)  
curl \-sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh \-s \-- \-b /usr/local/bin

It is not only **possible** and **appropriate**, it is the defining characteristic of a modern, "Hardened" Sysadmin workflow.

In the industry, we call this **"Shifting Left."** Instead of waiting for a hacker to find a vulnerability in your running server, you find it in the "Gold Template" before the server is even turned on.

Below is a robust **Bash script** designed for your Proxmox host. It uses libguestfs (a safer, more robust tool than qemu-nbd for handling LVM and partitions) to mount your VM's disk, generate an **SBoM** with **Syft**, and then immediately scan that SBoM for **CVEs** using **Grype**.

### **Prerequisites**

Run this on your Proxmox host shell to get the necessary tools:

Bash

\# Install safer mounting tools  
apt update && apt install \-y libguestfs-tools

\# Install Syft (SBoM Generator)  
curl \-sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh \-s \-- \-b /usr/local/bin

\# Install Grype (CVE Scanner)  
curl \-sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh \-s \-- \-b /usr/local/bin

---

### **The Script: sentinel-scan.sh**

Save this file as sentinel-scan.sh and make it executable (chmod \+x sentinel-scan.sh).

Bash

\#\!/bin/bash

\# \==============================================================================  
\# SCRIPT: sentinel-scan.sh  
\# PURPOSE: Mounts a Proxmox VM disk, generates an SBoM, and scans for CVEs.  
\# USAGE: ./sentinel-scan.sh \<VMID\>  
\# \==============================================================================

VMID=$1  
MOUNT\_POINT="/mnt/vm-${VMID}\-scan"  
TIMESTAMP=$(date \+"%Y%m%d-%H%M")  
REPORT\_DIR="./reports/${VMID}/${TIMESTAMP}"

\# 1\. Validation checks  
if \[ \-z "$VMID" \]; then  
    echo "❌ Error: Please provide a VMID. Usage: ./sentinel-scan.sh \<VMID\>"  
    exit 1  
fi

STATUS=$(qm status $VMID | awk '{print $2}')  
if \[ "$STATUS" \== "running" \]; then  
    echo "⚠️  WARNING: VM $VMID is RUNNING."  
    echo "   Scanning a running disk can be risky. It is recommended to stop the VM first."  
    read \-p "   Do you want to proceed with a Read-Only scan? (y/n) " \-n 1 \-r  
    echo  
    if \[\[ \! $REPLY \=\~ ^\[Yy\]$ \]\]; then  
        exit 1  
    fi  
fi

\# Locate the disk (Assumes first disk in local-lvm or similar, adjust grep as needed)  
\# A more robust config extraction:  
DISK\_PATH=$(qm config $VMID | grep \-o "vm-$VMID\-disk-\[0-9\]\*" | head \-n 1\)  
STORAGE=$(qm config $VMID | grep "scsi0" | awk \-F: '{print $2}')

\# Construct path based on standard Proxmox LVM paths (Adjust if using ZFS/Directory)  
FULL\_DISK\_PATH="/dev/pve/$DISK\_PATH"   
\# NOTE: If using ZFS, it might be /dev/zvol/rpool/data/$DISK\_PATH  
\# If unsure, check 'pvesm path \<storage:disk\>'

echo "🔍 Target Disk: $FULL\_DISK\_PATH"  
echo "📂 Creating report directory: $REPORT\_DIR"  
mkdir \-p "$REPORT\_DIR"  
mkdir \-p "$MOUNT\_POINT"

\# 2\. Mount the Disk (Safely using guestmount)  
echo "🚀 Mounting VM disk (Read-Only)..."  
\# \-i attempts to automatically find the OS root, even across LVMs  
guestmount \-a "$FULL\_DISK\_PATH" \-i \--ro "$MOUNT\_POINT"

if \[ $? \-ne 0 \]; then  
    echo "❌ Failed to mount disk. Check if 'libguestfs-tools' is installed."  
    exit 1  
fi

\# 3\. Generate SBoM (Software Bill of Materials)  
echo "📦 Generating SBoM with Syft..."  
syft dir:"$MOUNT\_POINT" \\  
    \--output cyclonedx-json="$REPORT\_DIR/sbom.json" \\  
    \--output text="$REPORT\_DIR/sbom\_summary.txt"

echo "   ✅ SBoM saved to $REPORT\_DIR/sbom.json"

\# 4\. Scan for CVEs (Vulnerabilities)  
echo "🛡️  Scanning for Vulnerabilities with Grype..."  
grype sbom:"$REPORT\_DIR/sbom.json" \\  
    \--fail-on high \\  
    \> "$REPORT\_DIR/cve\_report.txt"

\# Display a quick summary to the console  
echo "---------------------------------------------------"  
echo "   SCAN COMPLETE"  
echo "---------------------------------------------------"  
grep "Critical" "$REPORT\_DIR/cve\_report.txt" | wc \-l | awk '{print "   🔴 Critical Issues: " $1}'  
grep "High" "$REPORT\_DIR/cve\_report.txt" | wc \-l | awk '{print "   🟠 High Issues:     " $1}'  
echo "---------------------------------------------------"  
echo "📄 Full reports available in: $REPORT\_DIR"

\# 5\. Cleanup  
echo "🧹 Unmounting and cleaning up..."  
guestunmount "$MOUNT\_POINT"  
rmdir "$MOUNT\_POINT"  
echo "✅ Done."

### **How to use this workflow**

1. **Stop the VM:** qm stop 105  
2. **Run the Scan:** ./sentinel-scan.sh 105  
3. **Review:**  
   * The script generates a JSON SBoM (perfect for Git storage).  
   * It generates a text-based CVE report (perfect for you to read).

### **Why libguestfs-tools (guestmount)?**

In the previous chat, I mentioned qemu-nbd. While valid, guestmount is the **sysadmin superior** choice because:

1. **LVM Aware:** It automatically handles the complex Volume Groups (LVM) that Ubuntu 24.04 uses by default. You don't have to manually map /dev/mapper/ubuntu-vg.  
2. **Safety:** It uses a separate appliance to read the disk, reducing the risk of the host OS modifying the guest filesystem.

**Would you like to run a test scan on VM 105 now, or should we verify the storage path (ZFS vs LVM) of your Proxmox host first?**

\#\!/bin/bash

\# \==============================================================================  
\# SCRIPT: sentinel-scan.sh  
\# PURPOSE: Mounts a Proxmox VM disk, generates an SBoM, and scans for CVEs.  
\# USAGE: ./sentinel-scan.sh \<VMID\>  
\# \==============================================================================

VMID=$1  
MOUNT\_POINT="/mnt/vm-${VMID}-scan"  
TIMESTAMP=$(date \+"%Y%m%d-%H%M")  
REPORT\_DIR="./reports/${VMID}/${TIMESTAMP}"

\# 1\. Validation checks  
if \[ \-z "$VMID" \]; then  
    echo "❌ Error: Please provide a VMID. Usage: ./sentinel-scan.sh \<VMID\>"  
    exit 1  
fi

STATUS=$(qm status $VMID | awk '{print $2}')  
if \[ "$STATUS" \== "running" \]; then  
    echo "⚠️  WARNING: VM $VMID is RUNNING."  
    echo "   Scanning a running disk can be risky. It is recommended to stop the VM first."  
    read \-p "   Do you want to proceed with a Read-Only scan? (y/n) " \-n 1 \-r  
    echo  
    if \[\[ \! $REPLY \=\~ ^\[Yy\]$ \]\]; then  
        exit 1  
    fi  
fi

\# Locate the disk (Assumes first disk in local-lvm or similar, adjust grep as needed)  
\# A more robust config extraction:  
DISK\_PATH=$(qm config $VMID | grep \-o "vm-$VMID-disk-\[0-9\]\*" | head \-n 1\)  
STORAGE=$(qm config $VMID | grep "scsi0" | awk \-F: '{print $2}')

\# Construct path based on standard Proxmox LVM paths (Adjust if using ZFS/Directory)  
FULL\_DISK\_PATH="/dev/pve/$DISK\_PATH"   
\# NOTE: If using ZFS, it might be /dev/zvol/rpool/data/$DISK\_PATH  
\# If unsure, check 'pvesm path \<storage:disk\>'

echo "🔍 Target Disk: $FULL\_DISK\_PATH"  
echo "📂 Creating report directory: $REPORT\_DIR"  
mkdir \-p "$REPORT\_DIR"  
mkdir \-p "$MOUNT\_POINT"

\# 2\. Mount the Disk (Safely using guestmount)  
echo "🚀 Mounting VM disk (Read-Only)..."  
\# \-i attempts to automatically find the OS root, even across LVMs  
guestmount \-a "$FULL\_DISK\_PATH" \-i \--ro "$MOUNT\_POINT"

if \[ $? \-ne 0 \]; then  
    echo "❌ Failed to mount disk. Check if 'libguestfs-tools' is installed."  
    exit 1  
fi

\# 3\. Generate SBoM (Software Bill of Materials)  
echo "📦 Generating SBoM with Syft..."  
syft dir:"$MOUNT\_POINT" \\  
    \--output cyclonedx-json="$REPORT\_DIR/sbom.json" \\  
    \--output text="$REPORT\_DIR/sbom\_summary.txt"

echo "   ✅ SBoM saved to $REPORT\_DIR/sbom.json"

\# 4\. Scan for CVEs (Vulnerabilities)  
echo "🛡️  Scanning for Vulnerabilities with Grype..."  
grype sbom:"$REPORT\_DIR/sbom.json" \\  
    \--fail-on high \\  
    \> "$REPORT\_DIR/cve\_report.txt"

\# Display a quick summary to the console  
echo "---------------------------------------------------"  
echo "   SCAN COMPLETE"  
echo "---------------------------------------------------"  
grep "Critical" "$REPORT\_DIR/cve\_report.txt" | wc \-l | awk '{print "   🔴 Critical Issues: " $1}'  
grep "High" "$REPORT\_DIR/cve\_report.txt" | wc \-l | awk '{print "   🟠 High Issues:     " $1}'  
echo "---------------------------------------------------"  
echo "📄 Full reports available in: $REPORT\_DIR"

\# 5\. Cleanup  
echo "🧹 Unmounting and cleaning up..."  
guestunmount "$MOUNT\_POINT"  
rmdir "$MOUNT\_POINT"  
echo "✅ Done."

