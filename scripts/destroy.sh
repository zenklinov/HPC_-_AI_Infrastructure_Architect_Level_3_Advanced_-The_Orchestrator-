#!/bin/bash
set -e

echo ">>> [WARNING] Starting Universal Destroy Sequence for GPU Cluster..."

# 1. Delete Application & HPA
echo ">>> Removing Application Layer..."
kubectl delete -f ../k8s/hpa.yaml --ignore-not-found
kubectl delete -f ../k8s/deployment.yaml --ignore-not-found
kubectl delete namespace gpu-orchestrator --ignore-not-found

# 2. Delete Monitoring Stack
echo ">>> Uninstalling Prometheus & DCGM..."
helm uninstall prometheus-stack -n monitoring --ignore-not-found
kubectl delete namespace monitoring --ignore-not-found

# 3. Delete Device Plugin
echo ">>> Cleaning up Device Plugin..."
kubectl delete -f ../k8s/gpu-device-plugin.yaml --ignore-not-found

echo ">>> Cluster Cleaned. REMINDER: Manually destroy the EKS Cluster via Terraform or Console to stop hourly billing!"
