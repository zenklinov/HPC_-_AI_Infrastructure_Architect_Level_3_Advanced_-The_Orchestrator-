# AWS Infrastructure Cost Estimation

**WARNING**: GPU Cloud Infrastructure is expensive. This estimation assumes a baseline configuration for development and moderate testing. Always destroy resources when not in use.

## Estimated Function: ~$1.20 - $1.80 per hour (running)
*Monthly potential (24/7): ~$800 - $1,300 USD*

## Breakdown

### 1. Compute (The Heavy Lifter)
*   **Instance Type**: `g4dn.xlarge` (4 vCPUs, 16GB RAM, 1x NVIDIA T4 GPU)
*   **On-Demand Price**: ~$0.526/hour (us-east-1)
*   **Spot Price**: ~$0.15 - $0.20/hour (Recommended for stateless inference)
*   **EBS Storage**: 50GB gp3 per node (~$5/month)
*   **Scaling Assumption**: Min 1 node, Max 3 nodes.

### 2. Control Plane (EKS)
*   **EKS Cluster**: $0.10/hour (~$73/month)
*   This is a fixed cost regardless of worker node count.

### 3. Networking & Load Balancing
*   **Application Load Balancer (ALB)**: ~$0.0225/hour + LCU charges (approx $20/month base)
*   **NAT Gateway**: $0.045/hour (Optional: Use Public Subnets to save ~$32/month if strict private networking is not required, but strict arch demands NAT) -> **Included: ~$32/month**.

### 4. Observability and Storage
*   **Prometheus Volume**: 20GB EBS (~$2/month)
*   **CloudWatch Logs**: Ingest dependent (~$5/month estimated)

---

## Cost Optimization Strategy (Implemented)

1.  **Aggressive Downscaling**: HPA is tuned to scale strictly on demand.
2.  **Spot Instances**: `deploy.sh` configures Node Groups to prefer Spot capacity.
3.  **Strict Cleanup**: The `destroy.sh` script removes the expensive NAT Gateways and EKS Control Plane immediately.

> **Projected Cost for 4-Hour Lab Session**:
> (4 hours * $0.526 * 2 nodes) + (4 hours * $0.10 EKS) + (4 hours * $0.045 NAT)
> ≈ **$5.00 USD per session**
