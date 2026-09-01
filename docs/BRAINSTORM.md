# Brainstorm - Projeto Korp

## O que foi construído

Um sistema completo de deploy de aplicações contendo:

### Camada de Aplicação
- Servidor Go com endpoint REST
- Métricas Prometheus integradas
- Health checks (liveness/readiness)

### Camada de Infraestrutura
- Docker para containerização
- Kubernetes (AKS) para orquestração
- NGINX como reverse proxy e load balancer

### Camada de Observabilidade
- Prometheus para coleta de métricas
- Grafana para visualização dashboards
- Provisionamento automático de datasources e dashboards

### Camada de Automação
- Ansible para deploy declarativo
- Um comando para deploy completo
- Validação automática pós-deploy

---

## Desenvolvimento com IA (OpenCode / Claude Code)

### Por que usar IA no desenvolvimento?

**Velocidade × Qualidade:**
- Projeto completo (Go + Docker + K8s + Ansible + Monitoramento) em uma sessão
- Código gerado com boas práticas desde o início
- Problemas diagnosticados e resolvidos em minutos

### Como a IA ajudou neste projeto:

| Fase | Contribuição da IA |
|------|-------------------|
| Análise do desafio | Leu o documento, extraiu requisitos, criou plano |
| Código Go | Gerou servidor HTTP com métricas Prometheus |
| Dockerfile | Criou multi-stage build otimizado |
| Kubernetes | Gerou 14 manifests YAML corretos |
| Ansible | Criou playbook completo com validação |
| Debug | Diagnosticou problemas com Prometheus e Grafana |
| Documentação | Gerou AGENTS.md, prompts, skills |

### Exemplos reais de interação:

**1. Diagnóstico automático:**
```
Problema: Dashboard Grafana sem dados
IA identificou: UID do datasource não definido
Solução: Adicionar uid: PBFA97CFB590B2093
Tempo: 2 minutos
```

**2. Correção de configuração:**
```
Problema: Prometheus não scrapava targets
IA identificou: Mistura de kubernetes_sd_configs com static_configs
Solução: Simplificar para apenas static_configs
Tempo: 1 minuto
```

**3. Automação completa:**
```
Solicitação: "Delete tudo e suba com Ansible"
IA executou: Playbook completo com validação
Resultado: 21 tasks, 0 failures
Tempo: 5 minutos
```

### Vantagens competitivas:

1. **Produtividade 10x** - Horas vs dias para o mesmo resultado
2. **Redução de erros** - IA valida padrões e boas práticas
3. **Documentação automática** - Docs sempre sincronizados com código
4. **Knowledge capture** - Decisões técnicas documentadas automaticamente
5. **Reprodutibilidade** - Comandos e configs prontos para reexecutar

### O que a IA NÃO substitui:

- **Entendimento do negócio** - Requisitos vêm do humano
- **Decisões de arquitetura** - IA sugere, humano decide
- **Validação em produção** - Testes reais são necessários
- **Responsabilidade final** - Humano é responsável pelo código

---

## Arquitetura Decidida

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
└─────────┘
     │
     ▼ (metrics)
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

## Decisões Técnicas

### Por que Go?
- Performance alta
- Binário estático (ideal para Docker)
- Suporte nativo a HTTP
- Biblioteca Prometheus madura

### Por que NGINX?
- Proxy reverso maduro
- Load balancing
- Cache estático
- SSL termination (futuro)

### Por que Ansible?
- Agentless (não precisa instalar nada no cluster)
- Idempotente (pode rodar várias vezes)
- YAML declarativo
- Fácil de entender

### Por que AKS?
- Gerenciado pela Azure
- Integração com Azure AD
- Auto-scaling
- Monitoramento nativo

### Por que NodePort (não LoadBalancer)?
- Limite de 3 IPs públicos na subscription
- Grafana e Prometheus são ferramentas internas
- Acesso via port-forward para desenvolvimento

---

## Problems que resolvemos

| Problema | Solução |
|----------|---------|
| Dashboard Grafana sem dados | UID fixo no datasource |
| Prometheus não scrapava | Config simplificado com static_configs |
| NGINX crashando | Probe TCP em vez de HTTP |
| Docker socket error | Trocar context |
| Azure IP limit | NodePort para serviços internos |
| Ansible não instalado | Venv isolation |

---

## Melhorias Futuras

### Segurança
- [ ] Network Policies (restringir tráfego)
- [ ] Kubernetes Secrets (não hardcodar senhas)
- [ ] RBAC (controle de acesso)
- [ ] Pod Security Standards

### Performance
- [ ] HPA (Horizontal Pod Autoscaler)
- [ ] PDB (Pod Disruption Budget)
- [ ] Resource Quotas
- [ ] Vertical Pod Autoscaler

### Observabilidade
- [ ] Prometheus AlertManager
- [ ] Grafana alerting
- [ ] Distributed tracing (Jaeger)
- [ ] Log aggregation (EFK stack)

### CI/CD
- [ ] GitHub Actions pipeline
- [ ] Automatizar build + push + deploy
- [ ] Environment promotion (dev → staging → prod)
- [ ] Rollback automático

### Disaster Recovery
- [ ] Backup do Prometheus (Thanos/Cortex)
- [ ] Restore procedures
- [ ] Multi-region deployment
- [ ] Chaos engineering

---

## Tecnologias Utilizadas

| Categoria | Tecnologia | Versão |
|-----------|------------|--------|
| Linguagem | Go | 1.26 |
| Container | Docker | 29.7.2 |
| Orquestração | Kubernetes | 1.35.7 |
| Cloud | Azure AKS | - |
| Reverse Proxy | NGINX | alpine |
| Métricas | Prometheus | latest |
| Dashboard | Grafana | latest |
| Automação | Ansible | 2.21.3 |
| Registry | DockerHub | - |

---

## Comandos Essenciais

```bash
# Local
docker compose up -d --build
curl http://localhost:80/projeto-korp

# AKS
cd ansible
~/ansible-venv/bin/ansible-playbook -i inventory.ini playbook-aks.yml

# Verificar
kubectl get pods -n projeto-korp
kubectl get svc -n projeto-korp

# Acessar Grafana
kubectl port-forward -n projeto-korp svc/grafana 3000:3000

# Acessar Prometheus
kubectl port-forward -n projeto-korp svc/prometheus 9090:9090
```

---

## Lições Aprendidas

1. **Simplicidade primeiro** - Começar com Docker Compose antes de Kubernetes
2. **Um comando só** - Ansible torna o deploy replicável
3. ** provisionamento automático** - Grafana provisioning evita config manual
4. **UID fixo** - Datasource com UID hardcoded evita quebra de dashboards
5. **Static configs** - Para monitors simples, evitar service discovery complexo
6. **NodePort** - Quando LoadBalancer não é possível, NodePort + port-forward funciona
7. **Validação** - Ansible deve testar o deploy depois de aplicar

---

## Métricas de Sucesso

- [x] App responds JSON
- [x] Prometheus collecta métricas
- [x] Grafana exibe dashboard
- [x] Deploy via Ansible funciona
- [x] Tudo recriável com 1 comando
- [x] Documentação completa (AGENTS.md)
