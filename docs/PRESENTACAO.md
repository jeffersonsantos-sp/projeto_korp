# Documento de Apresentacao - Projeto Korp

## Guia para Entrevista Tecnica

---

## 1. Visao Geral do Projeto

### Objetivo
Criar um servico HTTP completo com:
- Aplicacao em Go com metricas Prometheus
- Infestrutura Docker local
- Deploy no Azure AKS
- Automacao total com Ansible
- Monitoramento com Grafana

### Ferramenta de Desenvolvimento: OpenCode (Claude Code)

**Este projeto foi desenvolvido utilizando o OpenCode (Claude Code)**, um assistente de programacao baseado em IA que acelerou significativamente o processo de desenvolvimento.

**O que e OpenCode:**
- CLI interativa para desenvolvimento de software
- Baseado no modelo Claude da Anthropic
- Integracao direta com terminal e sistema de arquivos
- Capacidade de ler, escrever e executar comandos

**Como foi usado neste projeto:**
1. **Geracao de codigo** - Servidor Go, Dockerfile, manifests Kubernetes
2. **Debug e troubleshooting** - Diagnostico de problemas com Prometheus e Grafana
3. **Automacao** - Criacao do playbook Ansible
4. **Documentacao** - Geracao automatica de docs
5. **Execucao de comandos** - Build de imagens, push para DockerHub, deploy no AKS

**Vantagens do uso de IA no desenvolvimento:**
- **Velocidade** - Projeto completo em horas, nao dias
- **Precisao** - Codigo gerado com boas praticas
- **Debug eficiente** - Problemas identificados e resolvidos rapidamente
- **Documentacao** - Docs sempre atualizados com o codigo
- **Reprodutibilidade** - Comandos e configs documentados automaticamente

---

## 2. Arquitetura

```
┌─────────────────────────────────────────────────────────────┐
│                      INTERNET                               │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                  AZURE AKS                                  │
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

---

## 3. Passo a Passo da Implementacao

### Fase 1: Servico HTTP em Go

**O que foi feito:**
- Criado servidor HTTP na porta 8080
- Endpoint `GET /projeto-korp` retorna JSON
- Endpoint `/metrics` para Prometheus
- Metricas: `http_requests_total`, `http_request_duration_seconds`, `service_up`

**Por que Go:**
- Performance alta para servicos HTTP
- Binario estatico (ideal para Docker)
- Biblioteca `prometheus/client_golang` madura
- Compilacao rapida

---

### Fase 2: Docker e Docker Compose

**Dockerfile (multi-stage build):**
- Stage 1: Build com `golang:1.26-alpine`
- Stage 2: Runtime com `alpine:latest`
- Imagem final: ~15MB

**Por que multi-stage:**
- Imagem final menor (~15MB vs ~300MB)
- Sem ferramentas de build no runtime
- Mais seguro

---

### Fase 3: Configuracao do NGINX

**Por que NGINX:**
- Proxy reverso maduro e performatico
- Load balancing nativo
- Cache de respostas
- SSL termination (extensivel)

---

### Fase 4: Monitoramento

**Prometheus:**
- Scraping via `static_configs`
- Metricas do servico Go

**Grafana:**
- Provisionamento automatico
- Datasource com UID fixo
- Dashboard com 4 paineis

---

### Fase 5: Kubernetes (AKS)

**Decisoes tecnicas:**
- **NGINX = LoadBalancer**: Entrada principal
- **Grafana/Prometheus = NodePort**: Limite de IPs
- **App = ClusterIP**: So acessivel via NGINX
- **2 replicas**: Alta disponibilidade

---

### Fase 6: Automacao com Ansible

**Playbook completo:**
- Conecta no AKS
- Aplica ConfigMaps, Deployments, Services
- Aguarda pods prontos
- Testa servico

**Por que Ansible:**
- Agentless
- Idempotente
- YAML declarativo
- Um comando para deploy completo

---

## 4. Problemas e Solucoes

| Problema | Solucao |
|----------|---------|
| Dashboard Grafana sem dados | UID fixo no datasource |
| Prometheus nao scrapava | Config simplificado com static_configs |
| NGINX crashando | Probe TCP em vez de HTTP |
| Docker socket error | Trocar context |
| Azure IP limit | NodePort para servicos internos |
| Ansible nao instalado | Venv isolation |

---

## 5. Como Demonstrar na Entrevista

### Demo 1: Executar Ansible
```bash
cd ansible
~/ansible-venv/bin/ansible-playbook -i inventory.ini playbook-aks.yml
```

### Demo 2: Verificar Pods
```bash
kubectl get pods -n projeto-korp
```

### Demo 3: Testar Servico
```bash
curl http://<nginx-ip>/projeto-korp
```

### Demo 4: Prometheus
```bash
kubectl port-forward -n projeto-korp svc/prometheus 9090:9090
```

### Demo 5: Grafana
```bash
kubectl port-forward -n projeto-korp svc/grafana 3000:3000
```

---

## 6. Justificativas Tecnicas

| Decisao | Justificativa |
|---------|---------------|
| Go em vez de Python/Node | Performance, binario estatico, Docker leve |
| Docker multi-stage | Imagem final menor, mais seguro |
| NGINX como proxy | Maduro, performatico, cache, SSL |
| Ansible em vez de Terraform | Agentless, idempotente, simples |
| Static configs no Prometheus | Simples, funciona em qualquer ambiente |
| NodePort em vez de LoadBalancer | Limite de IPs Azure, servicos internos |
| UID fixo no Grafana | Dashboard nao quebra ao recriar |

---

## 7. Metricas de Sucesso

| Metrica | Status |
|---------|--------|
| App retorna JSON | Feito |
| Prometheus coleta metricas | Feito |
| Grafana exibe dashboard | Feito |
| Deploy via Ansible funciona | Feito |
| Tudo recreavel com 1 comando | Feito |
| Documentacao completa | Feito |

---

## 8. Tecnologias Utilizadas

| Categoria | Tecnologia | Versao |
|-----------|------------|--------|
| Linguagem | Go | 1.26 |
| Container | Docker | 29.7.2 |
| Orquestracao | Kubernetes | 1.35.7 |
| Cloud | Azure AKS | - |
| Reverse Proxy | NGINX | alpine |
| Metricas | Prometheus | latest |
| Dashboard | Grafana | latest |
| Automacao | Ansible | 2.21.3 |
| Registry | DockerHub | - |

---

## 9. Perguntas Comuns da Entrevista

### "Por que nao usou Terraform?"
Ansible e agentless e mais simples para este caso. Terraform seria melhor para provisionar o cluster AKS em si, mas para deploy de aplicacoes, Ansible e mais adequado.

### "Como faria para escalar?"
- HPA (Horizontal Pod Autoscaler) baseado em CPU/memoria
- Cluster autoscaler para adicionar nos
- Multi-region para alta disponibilidade

### "Como garantir a seguranca?"
- Network Policies para restringir trafego
- Kubernetes Secrets para credenciais
- RBAC para controle de acesso
- Imagens Docker scan (Trivy)

### "Como faria CI/CD?"
- GitHub Actions para build automatico
- Push automatico para DockerHub
- Deploy automatico via Ansible
- Environment promotion (dev → staging → prod)
