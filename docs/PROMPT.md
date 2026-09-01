# Prompt - Projeto Korp

## Prompt Principal

```
Crie um projeto completo de infraestrutura moderna com as seguintes especificações:

SERVIÇO:
- Servidor HTTP em Go na porta 8080
- Endpoint GET /projeto-korp retornando JSON: {"nome": "Projeto Korp", "horario": "<UTC atual>"}
- Métricas Prometheus: http_requests_total, http_request_duration_seconds, service_up
- Endpoint /metrics para exposição das métricas

DOCKER:
- Dockerfile multi-stage (golang:1.26-alpine builder → alpine:latest runtime)
- Docker Compose com 4 containers: app, nginx, prometheus, grafana
- Rede bridge para comunicação entre containers
- NGINX como proxy reverso (porta 80 → 8080)

KUBERNETES (AKS):
- Namespace: projeto-korp
- 14 manifests YAML: deployments, services, configmaps
- NGINX: LoadBalancer (porta 80)
- Grafana: NodePort (porta 3000)
- Prometheus: NodePort (porta 9090)
- App: ClusterIP (porta 8080)
- 2 réplicas do app e do NGINX
- Health checks: liveness e readiness probes

MONITORAMENTO:
- Prometheus scrapeando o app via static_configs
- Grafana com provisionamento automático:
  - Datasource Prometheus (uid: PBFA97CFB590B2093)
  - Dashboard "HTTP Server Projeto Korp" com 4 painéis:
    - Service Status (stat)
    - Total Requests (timeseries)
    - Request Duration (timeseries)
    - Request Rate (stat)

ANSIBLE:
- Playbook para deploy completo no AKS
- Tasks: credenciais Azure, namespace, configmaps, deployments, services
- Validação: pods ready, endpoint testado, Prometheus target up
- Execução com um único comando

DOCKERHUB:
- Imagem: updateinformatica/projeto-korp:1.0
- Build e push automatizados

SAÍDA ESPERADA:
- Serviço respondendo via NGINX
- Prometheus coletando métricas
- Grafana exibindo dashboard com dados
- Tudo provisionado via Ansible com 1 comando
```

## Prompt Simplificado

```
Deploy completo de aplicação Go + NGINX + Prometheus + Grafana no Azure AKS usando Ansible, com imagem no DockerHub.
```

## Prompt para Refinamento

```
Analise o projeto criado e sugira melhorias em:
1. Segurança (network policies, secrets)
2. Performance (HPA, resource quotas)
3. Observabilidade (alerts, logs)
4. CI/CD (pipeline automatizado)
5. Disaster recovery (backup, restore)
```
