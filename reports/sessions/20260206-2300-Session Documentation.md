## Sentinel Project: Infrastructure Re-Baseline Report

**Date:** February 6, 2026

**Status:** **OPERATIONAL** (Storage & Messaging Layer Rebuilt)

---

### I. Index

1. [Executive Summary](https://www.google.com/search?q=%231-executive-summary)
2. [Detailed Progress Report](https://www.google.com/search?q=%232-detailed-progress-report)
3. [Updated Configuration & IaC](https://www.google.com/search?q=%233-updated-configuration--iac)
4. [Current Infrastructure State](https://www.google.com/search?q=%234-current-infrastructure-state)
5. [Roadmap: Phase II & III](https://www.google.com/search?q=%235-roadmap-phase-ii--iii)

---

### 1. Executive Summary

The Sentinel infrastructure has been successfully migrated from unstable local path storage to a distributed **Longhorn SAN**. We have resolved the "Disk Pressure" evictions by expanding the worker node volumes to **40GB** and implementing a robust **MetalLB** configuration. RabbitMQ is now accessible via a stable External IP on the local network.

---

### 2. Detailed Progress Report

* **Storage Overhaul:** Deployed Longhorn () across the cluster. Standardized worker node storage to 40GB/node.
* **Namespace Recovery:** Re-established the `sentinel` namespace following a full cluster purge to clear "Evicted" pod ghosts.
* **YAML Sanitization:** Resolved "Mapping Value" and "Expected Key" errors in deployment manifests caused by hidden formatting characters.
* **Networking:** Fixed a "Ghost IP" conflict where ClusterIP `10.43.40.0` was stuck in the K3s network registry.
* **Load Balancing:** Successfully integrated MetalLB to provide a VIP (`192.168.1.241`) for service ingress.

---

### 3. Updated Configuration & IaC Files

The following files are the current "Source of Truth" located in `~/sentinel-ops/cluster/`.

#### **RabbitMQ Service (`rabbitmq-service.yaml`)**

```yaml
apiVersion: v1
kind: Service
metadata:
  name: rabbitmq
  namespace: sentinel
spec:
  type: LoadBalancer
  selector:
    app: rabbitmq
  ports:
    - name: amqp
      port: 5672
      targetPort: 5672
    - name: http
      port: 15672
      targetPort: 15672

```

#### **Storage Class Configuration**

Longhorn is now the default `StorageClass`.

* **Provisioner:** `driver.longhorn.io`
* **Reclaim Policy:** `Delete` (can be updated to `Retain` for production)
* **Replica Count:** `2` (Optimized for 2-worker node topology)

---

### 4. Current Infrastructure State

| Component | Status | Internal IP | External Access |
| --- | --- | --- | --- |
| **K3s Control Plane** | UP | `192.168.1.50` | SSH / Port 6443 |
| **Longhorn UI** | UP | `svc/longhorn-frontend` | `192.168.1.50:8080` (Port-Forward) |
| **RabbitMQ Mgmt** | UP | `10.43.242.80` | **`192.168.1.241:15672`** |
| **Storage Pool** | HEALTHY | ~80GB Total | Longhorn Dash |

---

### 5. Roadmap

#### **Phase II: Persistence & Clustering (Immediate)**

* **Stateful Migration:** Convert `rabbitmq-deployment.yaml` into a `StatefulSet` to ensure Pods always attach to the same Longhorn Volume ID.
* **Clustering:** Configure RabbitMQ `peer_discovery` via Kubernetes DNS to merge the two running pods into one logical cluster.

#### **Phase III: Monitoring & Sentinel Logic**

* **Prometheus/Grafana:** Deploy monitoring to track disk IOPS on the new Longhorn volumes.
* **Sentinel Edge:** Begin deployment of the custom logic containers to consume RabbitMQ streams.

---

**Would you like me to generate the `StatefulSet` manifest now to replace the current Deployment and lock in your data persistence?**
