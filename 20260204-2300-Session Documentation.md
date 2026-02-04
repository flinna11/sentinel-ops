
Conversation opened. 1 read message.

Skip to content
Using Gmail with screen readers
2 of 8,363
20260204-report
Inbox
andy f <flinna11@gmail.com>
	
23:04 (6 minutes ago)
	
	
to me
## Infrastructure Migration & RabbitMQ Deployment Report

**Date:** February 4, 2026

**Project:** Proxmox K8s Cluster Recovery & Middleware Deployment

**Status:** In Progress (Blocked on Worker Image Pulls)

---

## Index

1. **Executive Summary**
2. **Completed Tasks (Detailed List)**
3. **Current Impediments**
4. **Roadmap for Future Work**

---

## 1. Executive Summary

The project involved recovering a 3-node RKE2 Kubernetes cluster (1 Master, 2 Workers) following a hostname change on the Master node. After resolving a "split-brain" etcd database state, we successfully installed Helm and deployed a High-Availability RabbitMQ cluster. Current efforts are focused on resolving container image pull failures on cloned worker nodes.

---

## 2. Detailed List of Completed Tasks

### Phase 1: Cluster Identity & etcd Recovery

* **Conflict Resolution:** Identified a mismatch between the OS hostname (`k8s-master`) and the etcd database identity (`andy-standard-pc...`).
* **Database Surgery:** Manually interacted with the etcd container using `etcdctl` to inspect member health.
* **Identity Reset:** Stopped the RKE2 service and purged the stale etcd name file (`/var/lib/rancher/rke2/server/db/etcd/name`) to force a re-initialization under the new hostname.
* **Node Cleanup:** Successfully removed the "ghost" node from the Kubernetes API.

### Phase 2: Package Management & Middleware

* **Helm Installation:** Deployed Helm v3.20.0 to the master node to handle complex application lifecycles.
* **Namespace Configuration:** Created a dedicated `rabbitmq` isolation zone.
* **RabbitMQ Deployment:** Deployed a 2-replica RabbitMQ StatefulSet using the Bitnami Chart.
* **Resource Adjustment:** Switched from Persistent Volume Claims (PVC) to `emptyDir` storage to bypass the lack of a storage provider in the lab environment.

---

## 3. Current Impediments

* **`ImagePullBackOff` on Worker-1:** The worker node is currently failing to resolve or download the RabbitMQ image from Docker Hub (`docker.io`).
* **Symptom:** `rpc error: code = NotFound desc = failed to resolve reference`.
* **Root Cause Suspect:** Cloned VM artifacts (duplicate Machine IDs) or internal `containerd` DNS caching issues.

---

## 4. Roadmap for Future Work

### Short-Term (Immediate Fixes)

1. **Worker Node Sanitization:**
* Restart `rke2-agent` on all workers.
* Clear `containerd` metadata database to force a fresh registry handshake.


2. **Manual Image Sourcing:**
* Use `crictl` to manually pull the RabbitMQ image to test connectivity.


3. **Service Exposure:**
* Patch the RabbitMQ service to `NodePort` to allow browser access via VM IP.



### Mid-Term (Stability & Storage)

1. **Storage Provisioning:** Install **Longhorn** or **OpenEBS** to allow RabbitMQ to persist data after pod restarts.
2. **Internal Load Balancing:** Configure an Ingress Controller (Nginx or Traefik) for cleaner URL access.

### Long-Term (Scaling)

1. **Cluster Expansion:** Add a third worker node to achieve a true high-availability quorum.
2. **Monitoring:** Deploy Prometheus and Grafana via Helm to monitor RabbitMQ message throughput.

---

**Next Step:** Whenever you are ready to resume, we will begin by clearing the `containerd` metadata on Worker-1 to fix the image pull error. Would you like me to prepare the specific cleanup script for you?

-- 
Andy F
flinna11@gmail.com

