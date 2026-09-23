# Observability Prometheus and Grafana

This repository demonstrates a complete observability and application deployment setup using Kind, Docker, Kubernetes, Prometheus, Grafana, and logging components.

## What is included

- A sample voting app with:
  - `vote/` — Python Flask front-end
  - `worker/` — .NET worker service
  - `result/` — Node.js real-time result dashboard
- Infrastructure examples for:
  - Redis
  - PostgreSQL
- Kubernetes manifests in `k8s-specifications/`
- Kind cluster helper files in `kind-cluster/`
- Terraform examples in `terraform-k8s-lab/`

## Kind cluster setup

Use the `kind-cluster/commands.md` file for step-by-step commands.

The Kind cluster is configured in `kind-cluster/config.yml` with one control-plane node and two workers.

### Recommended flow

1. Install Docker, kubectl, and Kind on your machine.
2. Create the Kind cluster:
   ```bash
   kind create cluster --config kind-cluster/config.yml
   ```
3. Deploy the voting app YAML files from `k8s-specifications/`.
4. Use `kubectl get pods -A` and `kubectl get svc -A` to verify resources.

## Observability stack

This repo supports metrics and logging stacks separately.

### Metrics

Install Prometheus and Grafana with Helm from `kind-cluster/commands.md`:
- `prometheus-community/kube-prometheus-stack`

This gives you:
- Prometheus for metrics collection
- Grafana for dashboards
- Alertmanager for alerting

### Logging

For logs, use a separate EFK-style stack:
- Fluent Bit for log collection
- Elasticsearch for storage and search
- Kibana for visualization

### Tracing

If you want tracing, add Jaeger or Tempo on top of the cluster.

## Docker and runtime requirements

- Docker must be installed and running
- `kubectl` must be configured for the Kind cluster
- Helm is recommended for installing Prometheus/Grafana and logging components

## Useful files

- `kind-cluster/commands.md` — Kind commands and observability Helm install steps
- `terraform-k8s-lab/install-runtime.sh` — runtime install script for Docker, kubectl, and AWS CLI
- `k8s-specifications/` — Kubernetes manifests used by the example application

## Notes

- The repository contains example deployment files and monitoring setup.
- Terraform state and runtime files under `terraform-k8s-lab/env/dev/` should not be tracked in Git.
- Use `gitignore` to avoid committing `.terraform/`, `*.tfstate`, and large provider binaries.

## Goal

Create a local Kubernetes observability lab with:
- a voting app running on Kind
- Prometheus/Grafana for metrics
- Fluent Bit + Elasticsearch + Kibana for logs
- optional Jaeger/Tempo for tracing

## Quick start

1. `kind create cluster --config kind-cluster/config.yml`
2. `kubectl apply -f k8s-specifications/`
3. Deploy monitoring and logging from `kind-cluster/commands.md`
4. Access dashboards via port-forward or NodePort

## Contact

If you want, I can also add a dedicated `kind-cluster/README.md` with commands for the full observability stack.
