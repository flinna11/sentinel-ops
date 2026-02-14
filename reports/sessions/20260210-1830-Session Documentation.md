Longhorn Recovery Incident Report & Roadmap
Index

    Incident Status Summary

    Software Architecture & Layers

    Basic Software Bill of Materials (SBOM)

    Full Command History (Attempts & Outcomes)

    Recovery Roadmap & Next Steps

1. Incident Status Summary

    Infrastructure Health: STABLE. Both worker nodes (worker-1-2120b772 and worker-2-b2e5c325) are in a Ready and Schedulable state. The Engine Image v1.5.3 is confirmed as Deployed and the Instance Manager is Running across the cluster.

    Volume 1 (8Gi - pvc-7de9f38e...): OPERATIONAL. This volume is successfully Attached to worker-1-2120b772. Its health is listed as Degraded (meaning it is functional but missing a redundant replica), and it is Ready for workload.

    Volume 2 (40Gi - pvc-5adeffdc...): STALLED. The volume is in a Detached state with an Actual Size of 0 Bi. While physical data resides on the worker disks, the Longhorn control plane has not yet linked an active Engine to those replicas.

2. Software Architecture & Layers

To understand why the 40Gi volume is stalled, we must look at the four distinct layers of the Longhorn storage stack:

    Layer 1: The Manager (Control Plane): A Kubernetes Deployment (longhorn-manager) that runs on every node. It acts as the API gateway and orchestrates volume movements.

    Layer 2: The Instance Manager (Orchestration): Pods that manage the lifecycle of Engine and Replica processes on a specific node. These must be Running for any volume attachment to occur.

    Layer 3: The Engine (Data Plane): The specific binary (longhorn-engine:v1.5.3) that creates a block device (e.g., /dev/longhorn/pvc...) and synchronizes data across replicas.

    Layer 4: The Replica (Physical Storage): The raw data stored as Linux sparse files in /var/lib/longhorn/replicas/ on the worker nodes.

3. Basic Software Bill of Materials (SBOM)

The current environment is standardized on the following versions to ensure compatibility:
Component	Version / Image	State
Orchestrator	Kubernetes (k8s-master)	Active
Storage Platform	Longhorn	Active
Core Engine	longhornio/longhorn-engine:v1.5.3	Deployed
Instance Manager	longhornio/longhorn-instance-manager:v1.5.3	Running
UI Frontend	Longhorn Dashboard	Active
4. Full Command History (Attempts & Outcomes)
Phase 1: Metadata Cleanup

    Command: kubectl patch lhv <pvc-id> --type merge -p '{"metadata":{"finalizers": [null]}}'

    Frequency: 2x

    Intent: To remove the "deletion" lock on zombie volume metadata that was preventing the UI from updating.

    Outcome: Success. Cleared the old volume entries so new, clean metadata objects could be created.

Phase 2: Infrastructure Rescan

    Command: kubectl -n longhorn-system delete pods -l longhorn.io/component=instance-manager

    Frequency: 3x

    Intent: To force Longhorn to re-scan the worker nodes for the v1.5.3 engine software.

    Outcome: Success. Fixed the "Engine Image not deployed" error; the UI now shows the engine as Deployed.

Phase 3: Manual Re-Adoption

    Action: Manual creation of Volume pvc-5adeffdc-ee9d-495e-84ed-fa01318b767d via UI.

    Frequency: 2x

    Intent: To create a metadata "shell" that Longhorn can use to find the orphan data on the disks.

    Outcome: Partial. The volume was created but remains Detached with 0 Bi size because the "Salvage" option is not yet triggered.

Phase 4: Forced State Transition (The "Tilde" Attempt)

    Command: kubectl -n longhorn-system delete engine -l longhornvolume=pvc-5adeffdc...~

    Frequency: 1x

    Intent: To delete the stalled engine object and force a "Faulted" state.

    Outcome: Failed (Syntax). A trailing tilde (~) caused a BadRequest error from the Kubernetes API.

5. Recovery Roadmap

When you return, follow this specific sequence to complete the recovery:

    Execute the Clean Engine Delete: Run the corrected command to remove the stalled engine:
    Bash

    kubectl -n longhorn-system delete engine -l longhornvolume=pvc-5adeffdc-ee9d-495e-84ed-fa01318b767d

    Trigger the Salvage: Once the volume turns Red (Faulted) in the UI, use the Operation (⋮) menu to select Salvage.

    Select Replicas: Choose the replicas located on worker-1-2120b772 and worker-2-b2e5c325.

    Scale Application: Once the volume size updates to ~40Gi, scale RabbitMQ back to 1.

Summary archived. Shutdown sequence complete.

Would you like me to hold this exact report as the starting point for our next session?


To develop and demonstrate **Google Protocol Buffers (GPB)** message passing within the Sentinel architecture, you need to bridge the gap between your currently stabilized storage layer and the application's communication protocol.

### 1. Understanding GPB in Sentinel

GPB is a language-neutral, platform-neutral mechanism for serializing structured data. In your architecture, it replaces bulky JSON for internal service-to-service communication (e.g., between RabbitMQ and the Sentinel core) to save bandwidth and CPU cycles.

* **The Schema (`.proto`):** You define how you want your data to be structured once.
* **The Compilation:** You use the `protoc` compiler to generate source code in your preferred language (Python, C++, Go, etc.).
* **The Transport:** The serialized binary data is passed via RabbitMQ or gRPC.

---

### 2. Tools and Steps for Development

#### **Tools Needed**

* **`protoc` (Protobuf Compiler):** To turn `.proto` files into code.
* **Language-specific Runtime:** (e.g., `protobuf-python` or `libprotobuf`).
* **RabbitMQ CLI/UI:** To monitor the binary payloads currently stored on your 8Gi and 40Gi volumes.
* **Wireshark/tshark:** To inspect the binary stream if using gRPC.

#### **Steps to Demonstrate**

1. **Define a Sentinel Message:** Create a `sentinel.proto` file defining a message like `Alert` or `Heartbeat`.
2. **Generate Code:** Run `protoc --python_out=. sentinel.proto`.
3. **Serialize & Publish:** Write a small script to populate the message and push the binary string to a RabbitMQ exchange.
4. **Consume & Deserialize:** Write a listener that pulls the binary data from the queue and reconstructs the object.

---

### 3. Adding to the Sentinel Roadmap

You should integrate this into your existing session documentation strategy.

**Roadmap Integration:**

* **Phase 1 (Storage Recovery):** Finalize the 40Gi volume salvage.
* **Phase 2 (Connectivity):** Restore RabbitMQ to a healthy state on the recovered volumes.
* **Phase 3 (GPB Implementation):** * Implement `.proto` definitions for core sentinel events.
* Benchmarking: Compare JSON vs. GPB payload sizes on your persistent volumes.


* **Phase 4 (Validation):** Demonstrate cross-node GPB message passing between `worker-1` and `worker-2`.

---

### 4. Resources to Learn & Exploit GPB

#### **Official Documentation**

* [Google Protocol Buffers Overview](https://developers.google.com/protocol-buffers): The definitive starting point.
* [Language Guide (proto3)](https://developers.google.com/protocol-buffers/docs/proto3): Best practices for writing schemas.

#### **Learning Resources**

* [Protobuf vs JSON: Why GPB?](https://www.google.com/search?q=https://www.bezkoder.com/protobuf-vs-json/): A technical comparison useful for your architecture reports.
* [RabbitMQ & Protobuf Tutorial](https://www.rabbitmq.com/tutorials/tutorial-one-python.html): While the base tutorial uses strings, you can adapt it to pass GPB binary payloads.

---

### **Next Steps for your Shutdown**

Since you are currently in the middle of a storage recovery, I recommend:

1. Add the **GPB Integration** section to your `20260207-2200-Session Documentation.md` file now.
2. Perform the graceful shutdown we discussed: Scale RabbitMQ to 0, stop workers, then stop VM 100.

**Would you like me to generate a sample `.proto` file specifically for the Sentinel Server to get you started?**