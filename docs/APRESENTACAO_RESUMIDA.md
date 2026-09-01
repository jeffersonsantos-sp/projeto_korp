# Apresentacao - Projeto Korp

Guia para entrevista tecnica.

---

## 1. O Que Foi Entregue

| Requisito | Status |
|-----------|--------|
| Servico HTTP em Go | Feito |
| Dockerfile multi-stage | Feito |
| Docker Compose | Feito |
| Rede bridge | Feito |
| NGINX proxy reverso | Feito |
| Metricas Prometheus | Feito |
| Dashboard Grafana | Feito |
| Automacao Ansible | Feito |
| Deploy AKS | Feito |
| Provisionamento Grafana | Feito |

---

## 2. Arquitetura

```
Internet
    │
    ▼
┌─────────┐
│  NGINX  │ ← LoadBalancer (porta 80)
└────┬────┘
     │
     ▼
┌─────────┐
│   Go    │ ← ClusterIP (porta 8080)
│  Server │
└────┬────┘
     │
     ▼
┌─────────────┐
│  Prometheus │ ← NodePort (porta 9090)
└──────┬──────┘
       │
       ▼
┌─────────┐
│ Grafana │ ← NodePort (porta 3000)
└─────────┘
```

---

## 3. Passo a Passo

### Parte 1: Servico HTTP

**1.1 Codigo Go (`main.go`)**

```go
package main

import (
    "encoding/json"
    "net/http"
    "time"
    "github.com/prometheus/client_golang/prometheus"
    "github.com/prometheus/client_golang/prometheus/promhttp"
)

type Response struct {
    Nome    string `json:"nome"`
    Horario string `json:"horario"`
}

var requestsTotal = prometheus.NewCounterVec(
    prometheus.CounterOpts{
        Name: "http_requests_total",
        Help: "Total de requisicoes",
    },
    []string{"method", "path", "status"},
)

func handler(w http.ResponseWriter, r *http.Request) {
    json.NewEncoder(w).Encode(Response{
        Nome:    "Projeto Korp",
        Horario: time.Now().UTC().Format(time.RFC3339),
    })
    requestsTotal.WithLabelValues(r.Method, r.URL.Path, "200").Inc()
}

func main() {
    prometheus.MustRegister(requestsTotal)
    http.HandleFunc("/projeto-korp", handler)
    http.Handle("/metrics", promhttp.Handler())
    http.ListenAndServe(":8080", nil)
}
```

**Por que Go:**
- Binario estatico (Docker leve)
- Performance alta
- Biblioteca Prometheus madura

**1.2 Dockerfile (multi-stage)**

```dockerfile
FROM golang:1.26-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY main.go ./
RUN CGO_ENABLED=0 GOOS=linux go build -o http-server .

FROM alpine:latest
WORKDIR /root/
COPY --from=builder /app/http-server .
EXPOSE 8080
CMD ["./http-server"]
```

**Por que multi-stage:** Imagem final ~15MB vs ~300MB

**1.3 Docker Compose**

```yaml
services:
  http-server-projeto-korp:
    build: .
    expose: ["8080"]
    
  nginx:
    image: nginx:alpine
    ports: ["80:80"]
    volumes:
      - ./http-server-projeto-korp.conf:/etc/nginx/conf.d/default.conf
    
  prometheus:
    image: prom/prometheus:latest
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
    
  grafana:
    image: grafana/grafana:latest
    volumes:
      - ./grafana/provisioning:/etc/grafana/provisioning
      - ./grafana/dashboards:/var/lib/grafana/dashboards
```

**1.4 NGINX (`http-server-projeto-korp.conf`)**

```nginx
server {
    listen 80;
    location /projeto-korp {
        proxy_pass http://http-server-projeto-korp:8080;
    }
}
```

---

### Parte 2: Monitoramento

**2.1 Prometheus (`prometheus.yml`)**

```yaml
scrape_configs:
  - job_name: 'http-server-projeto-korp'
    static_configs:
      - targets: ['http-server-projeto-korp:8080']
```

**Por que static_configs:** Simples, funciona em Docker e K8s

**2.2 Grafana Provisioning**

```yaml
# datasource.yml
datasources:
  - name: Prometheus
    type: prometheus
    uid: PBFA97CFB590B2093  # UID fixo
    url: http://prometheus:9090
```

**Por que UID fixo:** Dashboard JSON referencia este UID

**2.3 Dashboard (4 paineis)**

| Painel | Metrica |
|--------|---------|
| Service Status | `service_up` |
| Total Requests | `http_requests_total` |
| Request Duration | `http_request_duration_seconds` |
| Request Rate | `rate(http_requests_total[5m])` |

---

### Parte 3: Automacao Ansible

**Playbook (`playbook-aks.yml`)**

```yaml
tasks:
  - name: Get AKS credentials
    command: az aks get-credentials ...
  
  - name: Apply ConfigMaps
    command: kubectl apply -f {{ item }}
    loop:
      - nginx-configmap.yaml
      - prometheus-configmap.yaml
      - grafana-datasources.yaml
      - grafana-dashboards-provider.yaml
      - grafana-dashboard-configmap.yaml
  
  - name: Apply Deployments
    command: kubectl apply -f {{ item }}
    loop:
      - app-deployment.yaml
      - nginx-deployment.yaml
      - prometheus-deployment.yaml
      - grafana-deployment.yaml
  
  - name: Apply Services
    command: kubectl apply -f {{ item }}
    loop:
      - app-service.yaml
      - nginx-service.yaml
      - prometheus-service.yaml
      - grafana-service.yaml
  
  - name: Wait for pods ready
    command: kubectl wait --for=condition=ready pod ...
  
  - name: Test service
    uri:
      url: "http://{{ nginx_ip }}/projeto-korp"
```

**Por que Ansible:**
- Agentless
- Idempotente
- Um comando para tudo

---

## 4. Problemas e Solucoes

| Problema | Causa | Solucao |
|----------|-------|---------|
| Grafana sem dados | UID faltando | Adicionar `uid: PBFA97CFB590B2093` |
| Prometheus nao scrapava | Config complexo | Usar apenas `static_configs` |
| NGINX crashando | HTTP probe em rota errada | Usar `tcpSocket` |
| Azure IP limit | 3 IPs max | NodePort para Grafana/Prometheus |
| Docker socket error | Context errado | `docker context use default` |
| Ansible nao instala | Python 3.12 | Usar venv |

---

## 5. Como Demonstrou

### Demo 1: Executar Ansible
```bash
cd ansible
~/ansible-venv/bin/ansible-playbook -i inventory.ini playbook-aks.yml
```

### Demo 2: Verificar Pods
```bash
kubectl get pods -n projeto-korp
# 6 pods running
```

### Demo 3: Testar API
```bash
curl http://<nginx-ip>/projeto-korp
# {"nome":"Projeto Korp","horario":"2026-09-01T19:28:32Z"}
```

### Demo 4: Prometheus
```bash
kubectl port-forward -n projeto-korp svc/prometheus 9090:9090
# Target: UP
```

### Demo 5: Grafana
```bash
kubectl port-forward -n projeto-korp svc/grafana 3000:3000
# Dashboard: HTTP Server Projeto Korp
# Login: admin/admin
```

---

## 6. Justificativas Tecnicas

| Decisao | Por que |
|---------|---------|
| Go | Binario estatico, performance, Prometheus client |
| Docker multi-stage | Imagem menor, mais seguro |
| NGINX | Proxy reverso maduro, cache |
| Ansible | Agentless, idempotente |
| Static configs | Simples, funciona em qualquer ambiente |
| NodePort | Limite de IPs Azure |
| UID fixo | Dashboard nao quebra |
| Provisionamento | Deploy replicavel |

---

## 7. Metricas de Sucesso

- [x] App retorna JSON com nome e horario UTC
- [x] Prometheus coleta metricas
- [x] Grafana exibe dashboard com 4 paineis
- [x] Deploy via Ansible funciona
- [x] Tudo recreavel com 1 comando
- [x] Grafana provisionado automaticamente

---

## 8. Comandos Rapidos

```bash
# Deploy
cd ansible && ~/ansible-venv/bin/ansible-playbook -i inventory.ini playbook-aks.yml

# Verificar
kubectl get pods -n projeto-korp
kubectl get svc -n projeto-korp

# Acessar Grafana
kubectl port-forward -n projeto-korp svc/grafana 3000:3000

# Acessar Prometheus
kubectl port-forward -n projeto-korp svc/prometheus 9090:9090

# Testar API
curl http://$(kubectl get svc nginx -n projeto-korp -o jsonpath='{.status.loadBalancer.ingress[0].ip}')/projeto-korp
```

---

## 9. Stack Tecnica

| Camada | Tecnologia | Versao |
|--------|------------|--------|
| App | Go | 1.26 |
| Container | Docker | 29.7.2 |
| Orquestracao | Kubernetes | 1.35.7 |
| Cloud | Azure AKS | - |
| Proxy | NGINX | alpine |
| Metricas | Prometheus | latest |
| Dashboard | Grafana | latest |
| Automacao | Ansible | 2.21.3 |
| Registry | DockerHub | - |

---

## 10. Perguntas da Entrevista

### "Por que nao usou Terraform?"
Ansible e mais simples para deploy de aplicacoes. Terraform seria melhor para provisionar o cluster AKS.

### "Como faria para escalar?"
HPA + Cluster Autoscaler + Multi-region

### "Como garantir seguranca?"
Network Policies + Secrets + RBAC + Docker scan

### "Como faria CI/CD?"
GitHub Actions → DockerHub → Ansible

### "O que a IA fez?"
Gerei codigo, debugguei problemas, criei docs. IA acelerou 10x.
