# Projeto Korp - Agent Instructions

## Project Overview
Go HTTP server with Prometheus metrics, deployed to Azure AKS via Ansible. Serves JSON at `/projeto-korp` with metrics at `/metrics`.

## Quick Commands

### Local (Docker Compose)
```bash
docker compose up -d --build
curl http://localhost:80/projeto-korp
```

### AKS (Ansible)
```bash
cd ansible
~/ansible-venv/bin/ansible-playbook -i inventory.ini playbook-aks.yml
```

**Note:** Ansible is installed in a venv at `~/ansible-venv`. The system Python 3.12 blocks `pip install` directly.

### Build & Push Docker Image
```bash
docker build -t updateinformatica/projeto-korp:1.0 .
docker push updateinformatica/projeto-korp:1.0
```

## Architecture

### AKS Cluster
- **Resource Group:** `rg-english-jatel`
- **Cluster:** `aks-english-jatel`
- **Namespace:** `projeto-korp`

### Services
| Service | Type | Port |
|---------|------|------|
| NGINX (reverse proxy) | LoadBalancer | 80 |
| Grafana | NodePort | 3000 |
| Prometheus | NodePort | 9090 |
| Go app | ClusterIP | 8080 |

### Key Files
- `main.go` - Go server with Prometheus metrics
- `k8s/` - All Kubernetes manifests (14 files)
- `ansible/playbook-aks.yml` - Full AKS deployment
- `docker-compose.yml` - Local development

## Gotchas

### Grafana Datasource UID
The Grafana datasource must have `uid: PBFA97CFB590B2093` in `k8s/grafana-datasources.yaml`. The dashboard JSON hardcodes this UID. Without it, dashboards show no data.

### Prometheus Config
Use `static_configs` only in `k8s/prometheus-configmap.yaml`. Do NOT mix with `kubernetes_sd_configs` + `relabel_configs` - it causes targets to be dropped.

### NGINX Probes
NGINX probes use `tcpSocket` not `httpGet` because there's no `/` route in the proxy config.

### Docker Context
If `docker compose` fails with socket error, run: `docker context use default`

### Azure Public IP Limit
The subscription has a 3 public IP limit per region. Grafana and Prometheus use NodePort instead of LoadBalancer.

## Access After Deploy
```bash
# Get NGINX external IP
kubectl get svc nginx -n projeto-korp -o jsonpath='{.status.loadBalancer.ingress[0].ip}'

# Port-forward Grafana
kubectl port-forward -n projeto-korp svc/grafana 3000:3000

# Port-forward Prometheus
kubectl port-forward -n projeto-korp svc/prometheus 9090:9090
```

**Grafana:** admin/admin  
**Dashboard:** `/d/projeto-korp/http-server-projeto-korp`

## DockerHub
Image: `updateinformatica/projeto-korp:1.0`
