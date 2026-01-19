# GPU Cluster Architecture (The "Orchestrator")

## Architectural Overview
This system is designed to provide a highly scalable, observable, and cost-efficient environment for serving AI models requiring GPU acceleration. Unlike standard CPU workloads, GPU resources are expensive and require strict orchestration to ensure high utilization rates.

### Data Flow (End-to-End)
1.  **Ingress Layer**: HTTPS traffic enters via an AWS Application Load Balancer (ALB).
2.  **Routing**: The ALB forwards traffic to the Kubernetes Ingress Controller (Nginx).
3.  **Service Discovery**: K8s Service routes requests to available GPU Pods in the `gpu-orchestrator` namespace.
4.  **Compute Layer**:
    *   **Node Group**: AWS ASG with G4dn.xlarge instances (T4 GPUs).
    *   **Pod**: The model serving container allows `nvidia.com/gpu` access via the Device Plugin.
    *   **Execution**: CUDA kernels execute the inference task.
5.  **Observability Sidecar/Daemon**: DCGM Exporter scrapes GPU metrics (ECC errors, SM utilization) and exposes them to Prometheus.

### Diagram Reference
> *[Place architecture-diagram.png here]*
> **Diagram Instructions**:
> Visual representation must show:
> - User -> AWS ALB -> EKS Cluster.
> - K8s Autoscaler watching external metrics.
> - Prometheus scraping DCGM pod.
> - Dashboards visualizing "GPU Temperature" and "VRAM Usage".

## Design Decisions

### 1. GPU Passthrough vs. vGPU
We utilize **Direct Passthrough** (1 GPU per Pod) for simplicity and maximum performance isolation. MIG (Multi-Instance GPU) is reserved for A100 instances, which are outside the current budget scope.

### 2. Custom HPA Metrics
Standard CPU-based scaling is ineffective for Inference heavy workloads where VRAM might bottleneck before CPU. We use `DCGM_FI_DEV_GPU_UTIL` > 80% as the scaling trigger.

### 3. Spot Instance Strategy (Cost Optimization)
The architecture supports Mixed Instances Policy in the Node Group to leverage Spot Instances for stateless inference workloads, reducing compute costs by up to 70%.
