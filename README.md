# Projeto Korp

Deploy completo de aplicação Go + NGINX + Prometheus + Grafana no Azure AKS usando Ansible.

![Grafana Dashboard](imagem/Screenshot%20from%202026-09-01%2016-43-06.png)

---

## Sumario

- [Visao Geral](#visao-geral)
- [Arquitetura](#arquitetura)
- [Tecnologias](#tecnologias)
- [Estrutura do Projeto](#estrutura-do-projeto)
- [Quick Start](#quick-start)
- [Deploy com Ansible](#deploy-com-ansible)
- [Endpoints](#endpoints)
- [Monitoramento](#monitoramento)
- [Problemas e Solucoes](#problemas-e-solucoes)
- [Desenvolvimento com IA](#desenvolvimento-com-ia)
- [Melhorias Futuras](#melhorias-futuras)
- [Documentacao](#documentacao)

---

## Visao Geral

O Projeto Korp e um sistema completo de deploy de aplicações contendo:

- **Aplicacao:** Servidor Go com metricas Prometheus
- **Proxy:** NGINX como reverse proxy e load balancer
- **Containerizacao:** Docker multi-stage build
- **Orquestracao:** Kubernetes no Azure AKS
- **Monitoramento:** Prometheus + Grafana com dashboards automaticos
- **Automacao:** Ansible para deploy declarativo

### Resumo

| Componente | Descricao |
|------------|-----------|
| App | Go 1.26 com endpoint `/projeto-korp` |
| Metricas | Prometheus client com 3 metricas |
| Docker | Multi-stage build (~15MB) |
| K8s | 14 manifests YAML |
| Ansible | Playbook completo com validacao |
| Dashboard | 4 paineis Grafana provisionados |

---

## Arquitetura

```
┌─────────────────────────────────────────────────────────────┐
│                        INTERNET                             │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    AZURE AKS                                │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Namespace: projeto-korp                             │   │
│  │                                                      │   │
│  │  ┌─────────┐    ┌─────────┐    ┌─────────┐         │   │
│  │  │  NGINX  │───▶│   Go    │───▶│Prometheus│         │   │
│  │  │  :80    │    │  :8080  │    │  :9090  │         │   │
│  │  │   LB    │    │  CIP    │    │ NodePort│         │   │
│  │  └─────────┘    └─────────┘    └────┬────┘         │   │
│  │                                      │              │   │
│  │                                      ▼              │   │
│  │                               ┌─────────┐          │   │
│  │                               │ Grafana │          │   │
│  │                               │  :3000  │          │   │
│  │                               │NodePort │          │   │
│  │                               └─────────┘          │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

### Fluxo de Requisicao

```
Cliente → NGINX (:80) → Go App (:8080) → Resposta JSON
                           │
                           ▼ (async)
                      Prometheus (:9090) → Grafana (:3000)
```

### Tipos de Servico

| Servico | Tipo | Porta | Motivo |
|---------|------|-------|--------|
| NGINX | LoadBalancer | 80 | Entrada principal |
| Go App | ClusterIP | 8080 | So acessivel via NGINX |
| Prometheus | NodePort | 9090 | Limite de IPs Azure |
| Grafana | NodePort | 3000 | Limite de IPs Azure |

---

## Tecnologias

| Categoria | Tecnologia | Versao |
|-----------|------------|--------|
| Linguagem | Go | 1.26 |
| Container | Docker | 29.7.2 |
| Orquestracao | Kubernetes | 1.35.7 |
| Cloud | Azure AKS | - |
| Reverse Proxy | NGINX | Chainguard |
| Metricas | Prometheus | Chainguard |
| Dashboard | Grafana | Chainguard |
| Automacao | Ansible | 2.21.3 |
| Registry | DockerHub + Chainguard | - |

---

## Estrutura do Projeto

```
projeto_korp/
├── main.go                          # App Go com metricas Prometheus
├── go.mod / go.sum                  # Dependencias Go
├── Dockerfile                       # Build multi-stage
├── docker-compose.yml               # Dev local (4 servicos)
├── http-server-projeto-korp.conf    # Config NGINX
├── prometheus.yml                   # Config Prometheus (local)
│
├── k8s/                             # Manifests Kubernetes
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
│
├── ansible/
│   ├── inventory.ini                # Inventory local
│   ├── playbook.yml                 # Deploy local
│   └── playbook-aks.yml             # Deploy AKS
│
├── grafana/
│   └── provisioning/
│       ├── datasources/
│       │   └── datasource.yml
│       └── dashboards/
│           └── dashboard.yml
│
├── imagem/                          # Screenshots do projeto
│   ├── grafana-dashboard.png
│   ├── api-response.png
│   └── prometheus-targets.png
│
├── docs/
│   ├── PROMPT.md                    # Prompts para recriar
│   ├── SKILL.md                     # Skill definition
│   ├── BRAINSTORM.md                # Decisoes e melhorias
│   └── PRESENTACAO.md               # Guia para entrevista
│
├── AGENTS.md                        # Instrucoes para agentes
├── README.md                        # Este arquivo
└── desafio.md                       # Especificacao original
```

---

## Quick Start

### Pre-requisitos

- Docker e Docker Compose
- Azure CLI (`az`)
- kubectl
- Ansible (instalado via venv)

### Local (Docker Compose)

```bash
# Clonar repositorio
git clone https://github.com/jeffersonsantos-sp/projeto_korp.git
cd projeto_korp

# Build e rodar
docker compose up -d --build

# Testar
curl http://localhost:80/projeto-korp
```

**Resposta esperada:**
```json
{
  "nome": "Projeto Korp",
  "horario": "2026-09-01T19:28:32Z"
}
```

![Resposta da API](imagem/Screenshot%20from%202026-09-01%2016-43-17.png)

---

## Deploy com Ansible

### Preparar Ambiente

```bash
# Criar venv para Ansible
python3 -m venv ~/ansible-venv
~/ansible-venv/bin/pip install ansible

# Login no Azure
az login
```

### Executar Playbook

```bash
cd ansible
~/ansible-venv/bin/ansible-playbook -i inventory.ini playbook-aks.yml
```

### O que o Playbook faz:

1. **Conecta no AKS** - `az aks get-credentials`
2. **Limpa namespace** - Deleta se existir
3. **Aplica ConfigMaps** - NGINX, Prometheus, Grafana
4. **Aplica Deployments** - App, NGINX, Prometheus, Grafana
5. **Aplica Services** - LoadBalancer, NodePorts
6. **Aguarda pods** - Wait for ready
7. **Testa servico** - Valida endpoint

### Verificar Deploy

```bash
# Pods
kubectl get pods -n projeto-korp

# Services
kubectl get svc -n projeto-korp

# Logs
kubectl logs -n projeto-korp -l app=http-server-projeto-korp
```

---

## Endpoints

| Servico | Endereco | Credenciais |
|---------|----------|-------------|
| App | `http://<nginx-ip>/projeto-korp` | - |
| Grafana | `http://localhost:3000` | admin/admin |
| Prometheus | `http://localhost:9090` | - |

### Port-forward para Acesso Local

```bash
# Grafana
kubectl port-forward -n projeto-korp svc/grafana 3000:3000

# Prometheus
kubectl port-forward -n projeto-korp svc/prometheus 9090:9090
```

### Obter IP do NGINX

```bash
kubectl get svc nginx -n projeto-korp -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
```

---

## Monitoramento

### Grafana Dashboard

![Grafana Dashboard](imagem/Screenshot%20from%202026-09-01%2016-43-06.png)

**Dashboard:** HTTP Server Projeto Korp

| Painel | Metrica | Descricao |
|--------|---------|-----------|
| Service Status | `service_up` | Status do servico (UP/DOWN) |
| Total Requests | `http_requests_total` | Total de requisicoes por rota |
| Request Duration | `http_request_duration_seconds` | Tempo medio de resposta |
| Request Rate | `rate(http_requests_total)` | Taxa de requisicoes por segundo |

**Datasource:** Prometheus (uid: PBFA97CFB590B2093)

### Prometheus Targets

![Prometheus Targets](imagem/Screenshot%20from%202026-09-01%2016-45-40.png)

**Target:** `http-server-projeto-korp`  
**Status:** UP  
**Endpoint:** `http://http-server-projeto-korp:8080/metrics`

### Metricas Disponiveis

```promql
# Total de requisicoes
http_requests_total{method="GET", path="/projeto-korp", status="200"}

# Taxa de requisicoes (por segundo)
rate(http_requests_total[5m])

# Duracao media
http_request_duration_seconds{quantile="0.5"}

# Status do servico
service_up
```

---

## Problemas e Solucoes

### 1. Dashboard Grafana sem dados

**Causa:** Datasource provisioning nao definia `uid`

**Solucao:**
```yaml
# k8s/grafana-datasources.yaml
datasources:
  - name: Prometheus
    type: prometheus
    uid: PBFA97CFB590B2093  # ← ADICIONADO
    url: http://prometheus:9090
```

### 2. Prometheus nao scrapava targets

**Causa:** Mistura de `kubernetes_sd_configs` com `static_configs`

**Solucao:**
```yaml
# k8s/prometheus-configmap.yaml
scrape_configs:
  - job_name: 'http-server-projeto-korp'
    static_configs:  # ← APENAS ISTO
      - targets: ['http-server-projeto-korp:8080']
```

### 3. NGINX crashando

**Causa:** Health check HTTP em rota inexistente (`/`)

**Solucao:**
```yaml
# k8s/nginx-deployment.yaml
livenessProbe:
  tcpSocket:  # ← NAO httpGet
    port: 80
```

### 4. Azure IP limit

**Causa:** Subscription com limite de 3 IPs publicos

**Solucao:** Grafana e Prometheus usam NodePort em vez de LoadBalancer

### 5. Docker socket error

**Causa:** Docker context incorreto

**Solucao:**
```bash
docker context use default
```

### 6. Ansible nao instalado

**Causa:** Python 3.12 bloqueia `pip install` global

**Solucao:**
```bash
python3 -m venv ~/ansible-venv
~/ansible-venv/bin/pip install ansible
```

---

## Desenvolvimento com IA

### OpenCode (Claude Code)

Este projeto foi desenvolvido utilizando o **OpenCode (Claude Code)**, um assistente de programacao baseado em IA.

### Como a IA ajudou

| Fase | Contribuicao |
|------|--------------|
| Analise | Leu desafio, extraiu requisitos, criou plano |
| Codigo | Gerou Go, Dockerfile, manifests K8s |
| Debug | Diagnosticou Prometheus e Grafana |
| Automacao | Criou playbook Ansible |
| Documentacao | Gerou AGENTS.md, prompts, skills |

### Exemplos Reais

**Diagnostico automatico:**
```
Problema: Dashboard sem dados
IA identificou: UID faltando
Solucao: Adicionar uid: PBFA97CFB590B2093
Tempo: 2 minutos
```

**Correcao de config:**
```
Problema: Prometheus nao scrapava
IA identificou: Config complexo demais
Solucao: Usar apenas static_configs
Tempo: 1 minuto
```

### Vantagens

- **Velocidade** - Projeto completo em horas
- **Precisao** - Codigo com boas praticas
- **Debug** - Problemas resolvidos rapidamente
- **Documentacao** - Docs sempre atualizados

---

## Melhorias Futuras

### Seguranca
- [ ] Network Policies
- [ ] Kubernetes Secrets
- [ ] RBAC
- [ ] Pod Security Standards

### Performance
- [ ] HPA (Horizontal Pod Autoscaler)
- [ ] PDB (Pod Disruption Budget)
- [ ] Resource Quotas

### Observabilidade
- [ ] Prometheus AlertManager
- [ ] Grafana alerting
- [ ] Distributed tracing (Jaeger)

### CI/CD
- [ ] GitHub Actions
- [ ] Automatizar build + push + deploy
- [ ] Environment promotion

---

## Documentacao

| Arquivo | Descricao |
|---------|-----------|
| [AGENTS.md](AGENTS.md) | Instrucoes para agentes de IA |
| [docs/PROMPT.md](docs/PROMPT.md) | Prompts para recriar o projeto |
| [docs/SKILL.md](docs/SKILL.md) | Skill definition |
| [docs/BRAINSTORM.md](docs/BRAINSTORM.md) | Decisoes tecnicas e melhorias |
| [docs/PRESENTACAO.md](docs/PRESENTACAO.md) | Guia para entrevista |

---

## Comandos Essenciais

```bash
# === LOCAL ===
docker compose up -d --build          # Rodar local
curl http://localhost:80/projeto-korp # Testar

# === DEPLOY ===
cd ansible
~/ansible-venv/bin/ansible-playbook -i inventory.ini playbook-aks.yml

# === VERIFICAR ===
kubectl get pods -n projeto-korp      # Pods
kubectl get svc -n projeto-korp       # Services
kubectl logs -n projeto-korp -l app=http-server-projeto-korp  # Logs

# === ACESSAR ===
kubectl port-forward -n projeto-korp svc/grafana 3000:3000     # Grafana
kubectl port-forward -n projeto-korp svc/prometheus 9090:9090  # Prometheus

# === DOCKER ===
docker build -t updateinformatica/projeto-korp:1.0 .  # Build
docker push updateinformatica/projeto-korp:1.0         # Push
```

---

## DockerHub

**Imagem:** `updateinformatica/projeto-korp:1.0`

```bash
# Build
docker build -t updateinformatica/projeto-korp:1.0 .

# Push
docker push updateinformatica/projeto-korp:1.0
```

---

## Perguntas Comuns

### Por que nao usou Terraform?
Ansible e agentless e mais simples para deploy de aplicacoes. Terraform seria melhor para provisionar o cluster AKS.

### Como faria para escalar?
- HPA baseado em CPU/memoria
- Cluster autoscaler
- Multi-region

### Como garantir seguranca?
- Network Policies
- Kubernetes Secrets
- RBAC
- Docker scan (Trivy)

---

## Lições Aprendidas

1. **Simplicidade primeiro** - Docker Compose antes de Kubernetes
2. **Um comando so** - Ansible torna deploy replicavel
3. **UID fixo** - Evita quebra de dashboards
4. **Static configs** - Para monitores simples
5. **NodePort** - Quando LoadBalancer nao e possivel
6. **Validacao** - Ansible deve testar apos aplicar
7. **Documentacao** - AGENTS.md facilita reproducao

---

## Metas Alcançadas

- [x] App retorna JSON
- [x] Prometheus coleta metricas
- [x] Grafana exibe dashboard
- [x] Deploy via Ansible funciona
- [x] Tudo recreavel com 1 comando
- [x] Documentacao completa

---

## Licenca

Projeto para avaliacao tecnica.
