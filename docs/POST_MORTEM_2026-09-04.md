# Post-Mortem: HTTP Server Fora do Ar - 2026-09-04

## Resumo

O servidor HTTP `http-server-projeto-korp` no cluster AKS (`aks-english-jatel`) ficou fora do ar por **aproximadamente 1h49m** (desde a criação do namespace às 15:55 até a correção às 17:47). O deployment estava com **0 réplicas**.

## Timeline

| Hora (BRT) | Evento |
|------------|--------|
| 15:55 | Namespace `projeto-korp` criado, deployments iniciados |
| ~16:00 | Deploy com imagem `projeto-korp:2.7` funcional, pods rodando |
| ~16:10 | Deploy com imagem inexistente `projeto-korp:2.7.7` tentado |
| ~16:10 | `ImagePullBackOff` - pod não conseguiu puxar imagem |
| ~16:14 | Readiness probe falhou: `connection refused :8080/metrics` |
| ~16:15 | Réplicas escaladas para 0 (todos os ReplicaSets) |
| 17:47 | Correção: `kubectl scale --replicas=1` |
| 17:48 | Pod `1/1 Running`, todos os endpoints funcionando |

## Causa Raiz

**Deployment escalado para 0 réplicas.**

O deployment `http-server-projeto-korp` teve seu `replicas` definido como `0`, resultando em nenhum pod rodando. Não foi possível determinar automaticamente se foi:
- Um `kubectl scale` manual acidental
- Um deploy via Ansible que setou `replicas: 0`
- Uma tentativa de rollback que falhou

## Impacto

- **Duração:** ~1h49m
- **Serviços afetados:** HTTP server (API `/projeto-korp`)
- **Serviços não afetados:** NGINX, Prometheus, Grafana (continuaram rodando)
- **Dados perdidos:** Nenhum (aplicação stateless)
- **Usuários afetados:** Todos que acessavam `/projeto-korp` via NGINX

## Ações Corretivas Realizadas

```bash
kubectl scale deployment http-server-projeto-korp -n projeto-korp --replicas=1
```

## Verificação Pós-Correção

| Endpoint | Status | Response |
|----------|--------|----------|
| `/health` | 200 | `{"status":"healthy","service":"http-server-projeto-korp"}` |
| `/projeto-korp` | 200 | `{"nome":"Projeto Korp","horario":"2026-09-04T17:51:42-03:00"}` |
| `/metrics` | 200 | Prometheus metrics output |

## Lições Aprendidas

1. **Falta de PodDisruptionBudget:** Não há PDB para garantir mínimo de réplicas
2. **Falta de monitoramento de disponibilidade:** Nenhum alerta disparou quando os pods ficaram zero
3. **Imagem inexistente:** Tentativa de deploy com tag `2.7.7` que não existe no DockerHub
4. **Readiness probe aponta para `/metrics`:** Se a app demorar para subir, Kubernetes mata o pod antes de ficar pronto

## Recomendações

### Imediatas (P0)
- [ ] Criar `PodDisruptionBudget` com `minAvailable: 1` para http-server
- [ ] Verificar se a imagem `projeto-korp:2.7` existe no DockerHub e está atualizada

### Curto Prazo (P1)
- [ ] Adicionar monitoramento de disponibilidade (ex: `kube_deployment_status_replicas_available`)
- [ ] Configurar alerta quando réplicas disponíveis < 1
- [ ] Revisar readiness probe (considerar usar `/health` em vez de `/metrics`)

### Médio Prazo (P2)
- [ ] Implementar CI/CD com validação de imagem antes do deploy
- [ ] Adicionar `kubectl rollout status` no pipeline Ansible
- [ ] Documentar procedimento de rollback

## Comandos de Referência

```bash
# Verificar status do deployment
kubectl get deployment http-server-projeto-korp -n projeto-korp

# Ver logs do pod
kubectl logs -n projeto-korp -l app=http-server-projeto-korp --tail=100

# Ver eventos
kubectl get events -n projeto-korp --sort-by='.lastTimestamp'

# Testar endpoints
kubectl exec -n projeto-korp deploy/http-server-projeto-korp -- wget -qO- http://localhost:8080/health
```

---
**Autor:** opencode  
**Data:** 2026-09-04  
**Status:** RESOLVIDO
