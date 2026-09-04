# Post-Mortem: [TÍTULO DO INCIDENTE] - [DATA]

## Resumo

[1-2 frases descrevendo o que aconteceu]

## Timeline

| Hora (BRT) | Evento |
|------------|--------|
| HH:MM | Início do incidente |
| HH:MM | Investigação iniciada |
| HH:MM | Causa raiz identificada |
| HH:MM | Correção aplicada |
| HH:MM | Serviço restaurado |

## Causa Raiz

[Descrição técnica da causa raiz. Ser específico e baseado em evidências.]

## Impacto

- **Duração:** [tempo total do incidente]
- **Serviços afetados:** [lista de serviços]
- **Usuários afetados:** [número ou descrição]
- **Dados perdidos:** [Nenhum / descrição]

## Ações Corretivas Realizadas

```bash
# Comandos executados para resolver
kubectl scale deployment <name> -n <ns> --replicas=1
```

## Verificação Pós-Correção

| Endpoint/Componente | Status | Evidence |
|---------------------|--------|----------|
| `/health` | 200 OK | `{"status":"healthy"}` |
| `/api` | 200 OK | Response body |

## Lições Aprendidas

1. **[Lição 1]:** [Descrição]
2. **[Lição 2]:** [Descrição]
3. **[Lição 3]:** [Descrição]

## Recomendações

### Imediatas (P0)
- [ ] [Ação que deve ser tomada imediatamente]

### Curto Prazo (P1)
- [ ] [Ação para as próximas 1-2 semanas]

### Médio Prazo (P2)
- [ ] [Ação para o próximo mês]

## Comandos de Referência

```bash
# Verificar status
kubectl get all -n <namespace>

# Ver logs
kubectl logs -n <namespace> -l app=<app> --tail=100

# Ver eventos
kubectl get events -n <namespace> --sort-by='.lastTimestamp'

# Testar endpoint
kubectl exec -n <namespace> deploy/<app> -- wget -qO- http://localhost:8080/health
```

---
**Autor:** [nome]
**Data:** [data]
**Status:** RESOLVIDO
