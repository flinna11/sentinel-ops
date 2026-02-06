# **MASTER RECOVERY ARCHIVE: "client\_sentinel"**

**Project Name:** Sentinel of Stone: Secure Hybrid Stack & Private Cloud

**Configuration ID:** OPTIPLEX-KATA-2025-V16.5

**Date:** December 26, 2025

**Author:** flinna11 (Andy)

**Status:** **DEPLOYED & HARDENED (OFFLINE FOR MAINTENANCE)**

---

## **🗂️ Index**

1. [**Executive Summary**](https://www.google.com/search?q=%231-executive-summary)  
2. [**Hardware Specifications & BIOS**](https://www.google.com/search?q=%232-hardware-specifications--bios)  
3. [**Logical Architecture & Topology**](https://www.google.com/search?q=%233-logical-architecture--topology)  
4. [**Ubuntu Pro & Security Lifecycle**](https://www.google.com/search?q=%234-ubuntu-pro--security-lifecycle)  
5. [**Networking: The "King George" Anchor**](https://www.google.com/search?q=%235-networking-the-king-george-anchor)  
6. [**Remote Access: Ed25519 Hardening**](https://www.google.com/search?q=%236-remote-access-ed25519-hardening)  
7. [**Automated Maintenance & Patch Management**](https://www.google.com/search?q=%237-automated-maintenance--patch-management)  
8. [**Kubernetes Core (MicroK8s v1.31)**](https://www.google.com/search?q=%238-kubernetes-core-microk8s-v131)  
9. [**Cybersecurity: Kata Isolation & Cgroup Resolution**](https://www.google.com/search?q=%239-cybersecurity-kata-isolation--cgroup-resolution)  
10. [**Docker Stack: Nextcloud & Immich**](https://www.google.com/search?q=%2310-docker-stack-nextcloud--immich)  
11. [**Storage Architecture & Persistence Paths**](https://www.google.com/search?q=%2311-storage-architecture--persistence-paths)  
12. [**Backup Strategy: Rclone "Sentinel" Crypt**](https://www.google.com/search?q=%2312-backup-strategy-rclone-sentinel-crypt)  
13. [**Stability Appendix: RCA & Key Learnings**](https://www.google.com/search?q=%2313-stability-appendix-rca--key-learnings)

---

## **1\. Executive Summary**

The "Sentinel of Stone" is a production-grade private cloud node hosted on a Dell Optiplex i7-4770. The system leverages a hybrid container strategy: **MicroK8s** for orchestrated security auditing (via Kata Containers) and **Docker Compose** for high-throughput media and file hosting. The node is now stabilized, with hardware-level network fixes and kernel-level cgroup corrections in place.

## **2\. Hardware Specifications & BIOS**

* **CPU:** Intel Core i7-4770 (4 Cores / 8 Threads).  
* **RAM:** 16GB DDR3.  
* **NIC:** Intel I217-LM (Gigabit Ethernet).  
* **BIOS Hardening:** Secure Boot Enabled; Admin/System Passwords set; I/O ports (Serial/Parallel) disabled to reduce attack surface.

## **3\. Logical Architecture & Topology**

* **Host OS:** Ubuntu 24.04.3 LTS (Kernel 6.8.0-90-generic).  
* **Runtime A:** MicroK8s (Orchestration for security tools).  
* **Runtime B:** Kata Containers (QEMU-backed isolation for untrusted workloads).  
* **Runtime C:** Docker Engine (Application layer for Nextcloud/Immich).

## **4\. Ubuntu Pro & Security Lifecycle**

* **Status:** Active (Free Personal Subscription).  
* **Security Coverage:** ESM-Infra and ESM-Apps enabled until **2034**.  
* **Livepatch:** Enabled (Kernel security updates applied without reboots).

## **5\. Networking: The "King George" Anchor**

* **Static IP:** `192.168.1.50` anchored via `systemd-networkd`.  
* **Stability Fix:** Hardware Energy Efficient Ethernet (EEE) disabled on `eno1` via `networkd-dispatcher` to prevent carrier drops/flapping.

## **6\. Remote Access: Ed25519 Hardening**

* **Protocol:** SSH strictly limited to **Ed25519** elliptic-curve keys.  
* **Policy:** `PasswordAuthentication no`, `PermitRootLogin no`.  
* **Access:** Managed from local `penguin` machine and Windows PowerShell.

## **7\. Automated Maintenance & Patch Management**

* **Tool:** `unattended-upgrades` configured for security repos.  
* **Reboot Policy:** Automatic reboots at 03:00 AM only when a kernel change is required.

## **8\. Kubernetes Core (MicroK8s v1.31)**

* **Add-ons:** DNS, Storage, Metrics-Server.  
* **Runtime:** Integrated with `containerd` and configured to support `kata` as a `runtimeClassName`.

## **9\. Cybersecurity: Kata Isolation & Cgroup Resolution**

* **The Proof:** Verified isolation by comparing Host Kernel (`6.8.x`) vs. Pod Kernel (`5.15.x`).  
* **The Fix:** Resolved `FailedCreatePodSandBox` by updating GRUB to ensure the cgroup v2 mountpoint was correctly initialized for the containerd shim task.

## **10\. Docker Stack: Nextcloud & Immich**

* **Nextcloud:** Private cloud for document storage and syncing.  
* **Immich:** High-performance photo backup and management.  
* **Performance Note:** Initial ML indexing utilized **\~236% CPU**; idle usage stabilized at **\~14%**.

## **11\. Storage Architecture & Persistence Paths**

All stateful data is centralized in `/data` for ease of backup:

* **Nextcloud:** `/data/nextcloud/data` | `/data/nextcloud/db`  
* **Immich:** `/data/immich/library` | `/data/immich/postgres`

## **12\. Backup Strategy: Rclone "Sentinel" Crypt**

* **Primary Remote:** `usb_backup` (Local Disk).  
* **Security Layer:** `sentinel_crypt` (Overlaying the USB remote).  
* **Encryption:** Standard filename/directory encryption to protect PII (Personally Identifiable Information) in case of hardware theft.

## **13\. Stability Appendix: RCA & Key Learnings**

### **Technical Root Cause Analysis (RCA):**

1. **Network Flapping:** The Intel I217-LM NIC was entering a "sleep" state during low traffic. **Learning:** Always disable EEE on server-grade Linux deployments.  
2. **Kata Sandboxing Failures:** Ubuntu 24.04 uses cgroup v2 by default, which initially conflicted with the container runtime shim. **Learning:** Manual cgroup mountpoint verification via GRUB is essential for older hardware running modern 6.x kernels.  
3. **Isolation Verification:** Running `uname -r` inside a Kata-enabled pod is the only definitive way to prove hardware-level virtualization is active.

---

**Archive Verified:** December 26, 2025

**Report Version:** v16.5

**End of Report: client\_sentinel.md** **Action Required:** System is currently `SHUTDOWN`. On next boot, finalize the `sentinel_crypt` password/salt documentation.

