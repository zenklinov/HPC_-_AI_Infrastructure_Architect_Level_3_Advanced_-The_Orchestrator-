#!/bin/bash
set -e

echo ">>> [Level 3] Starting GPU Cluster Orchestration..."

# 1. Create Namespace
echo ">>> Creating Namespace 'gpu-orchestrator'..."
kubectl apply -f ../k8s/namespace.yaml

# 2. Deploy NVIDIA Device Plugin (Critical for GPU Passthrough)
echo ">>> Deploying Nvidia Device Plugin..."
kubectl apply -f ../k8s/gpu-device-plugin.yaml

# 3. Setup Monitoring Stack (Prometheus + Grafana + DCGM)
echo ">>> Installing Prometheus Stack (Helm)..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm upgrade --install prometheus-stack prometheus-community/kube-prometheus-stack \
  --namespace monitoring --create-namespace \
  -f ../monitoring/prometheus-values.yaml

echo ">>> Deploying DCGM Exporter (GPU Metrics Source)..."
kubectl apply -f ../monitoring/dcgm-exporter.yaml

# 4. Deploy Application
echo ">>> Deploying GPU Inference Application..."
kubectl apply -f ../k8s/deployment.yaml

# 5. Apply Auto-Scaling Policies
echo ">>> Configuring HPA (GPU-Usage Based)..."
kubectl apply -f ../k8s/hpa.yaml

echo ">>> Deployment Complete. Waiting for Pods..."
kubectl get pods -n gpu-orchestrator
