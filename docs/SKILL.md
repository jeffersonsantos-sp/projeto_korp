# Skill - Deploy Go + K8s + Ansible

## Nome
`go-aks-ansible-deploy`

## Descrição
Skill para deploy de aplicação Go com monitoramento (Prometheus + Grafana) no Azure AKS usando Ansible como ferramenta de automação.

## Trigger
- "Deploy de aplicação Go no AKS"
- "Criar infraestrutura com Ansible"
- "Subir serviço com Prometheus e Grafana"
- "Automatizar deploy Kubernetes"

## Pré-requisitos
- Azure CLI (`az`) configurado
- kubectl instalado
- Docker instalado
- Ansible instalado (recomendado: venv)
- Conta DockerHub

## Workflow

### Fase 1: Desenvolvimento Local
```bash
# 1. Criar servidor Go
# 2. Criar Dockerfile
# 3. Testar localmente
docker compose up -d --build
curl http://localhost:80/projeto-korp
```

### Fase 2: Containerização
```bash
# 1. Build da imagem
docker build -t <dockerhub-user>/<image>:<tag> .

# 2. Push para DockerHub
docker push <dockerhub-user>/<image>:<tag>
```

### Fase 3: Manifests Kubernetes
```bash
# Criar estrutura k8s/
# - namespace.yaml
# - *-deployment.yaml
# - *-service.yaml
# - *-configmap.yaml
```

### Fase 4: Automação Ansible
```bash
# Criar playbook com tasks:
# 1. Get AKS credentials
# 2. Delete namespace (clean deploy)
# 3. Apply all manifests
# 4. Wait for pods ready
# 5. Validate deployment
```

### Fase 5: Deploy
```bash
ansible-playbook -i inventory.ini playbook-aks.yml
```

## Estrutura de Arquivos

```
projeto/
├── main.go                    # App Go
├── go.mod / go.sum            # Dependências
├── Dockerfile                 # Build multi-stage
├── docker-compose.yml         # Dev local
├── k8s/                       # Manifests Kubernetes
│   ├── namespace.yaml
│   ├── app-deployment.yaml
│   ├── app-service.yaml
│   ├── nginx-configmap.yaml
│   ├── nginx-deployment.yaml
│   ├── nginx-service.yaml
│   ├── prometheus-configmap.yaml
│   ├── prometheus-deployment.yaml
│   ├── prometheus-service.yaml
│   ├── grafana-datasources.yaml
│   ├── grafana-dashboards-provider.yaml
│   ├── grafana-dashboard-configmap.yaml
│   ├── grafana-deployment.yaml
│   └── grafana-service.yaml
├── ansible/
│   ├── inventory.ini
│   ├── playbook.yml           # Docker Compose local
│   └── playbook-aks.yml       # Deploy AKS
├── grafana/
│   └── provisioning/
│       ├── datasources/
│       └── dashboards/
└── AGENTS.md                  # Instruções agentes
```

## Gotchas Conhecidos

| Problema | Solução |
|----------|---------|
| Grafana sem dados | Adicionar `uid: PBFA97CFB590B2093` no datasource |
| Prometheus target dropped | Usar apenas `static_configs`, não misturar com `kubernetes_sd_configs` |
| NGINX probe falhando | Usar `tcpSocket` em vez de `httpGet` |
| Docker socket error | `docker context use default` |
| Azure IP limit | Usar NodePort em vez de LoadBalancer |
| Ansible não encontrado | Instalar em venv: `python3 -m venv ~/ansible-venv` |

## Validação Pós-Deploy

```bash
# Pods
kubectl get pods -n projeto-korp

# Services
kubectl get svc -n projeto-korp

# Prometheus target
kubectl exec -n projeto-korp <prometheus-pod> -- wget -qO- http://localhost:9090/api/v1/targets

# Teste endpoint
curl http://<nginx-ip>/projeto-korp
```

## Extensões Possíveis

1. **CI/CD Pipeline** - GitHub Actions para build automático
2. **Network Policies** - Restringir tráfego entre pods
3. **Secrets** - Gerenciar credenciais via Kubernetes Secrets
4. **HPA** - Autoscaling baseado em métricas
5. **Ingress** - TLS/SSL com cert-manager
6. **Logging** - FLuentd + Elasticsearch
7. **Alerting** - Prometheus AlertManager
