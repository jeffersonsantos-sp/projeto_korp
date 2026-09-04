#!/bin/bash
# generate-postmortem.sh - Generate post-mortem document from incident data
# Usage: ./generate-postmortem.sh <namespace> <incident-title>

set -e

NAMESPACE=${1:?"Usage: $0 <namespace> <incident-title>"}
TITLE=${2:?"Usage: $0 <namespace> <incident-title>"}
DATE=$(date +%Y-%m-%d)
TIME=$(date +%H-%M)
OUTPUT_FILE="docs/POST_MORTEM_${DATE}.md"

# Collect incident data
echo "Collecting incident data for namespace: $NAMESPACE"

# Get current status
ALL_RESOURCES=$(kubectl get all -n "$NAMESPACE" -o wide 2>&1)
EVENTS=$(kubectl get events -n "$NAMESPACE" --sort-by='.lastTimestamp' 2>&1 | tail -20)
DEPLOYMENTS=$(kubectl get deployments -n "$NAMESPACE" -o json 2>&1)

# Identify problems
UNHEALTHY_DEPS=$(echo "$DEPLOYMENTS" | jq -r '.items[] | select(.status.availableReplicas == 0 or .status.availableReplicas == null) | .metadata.name' 2>/dev/null)
PROBLEM_PODS=$(kubectl get pods -n "$NAMESPACE" -o json | jq -r '.items[] | select(.status.phase != "Running" or (.status.containerStatuses[]? | select(.ready == false))) | .metadata.name' 2>/dev/null | sort -u)

# Generate post-mortem
cat > "$OUTPUT_FILE" << EOF
# Post-Mortem: ${TITLE} - ${DATE}

## Resumo

Incidente no namespace \`${NAMESPACE}\` envolvendo ${TITLE}.

## Timeline

| Hora | Evento |
|------|--------|
| ${TIME} | Investigação iniciada |

## Status Atual

\`\`\`
${ALL_RESOURCES}
\`\`\`

## Eventos Recentes

\`\`\`
${EVENTS}
\`\`\`

## Componentes Afetados

EOF

if [ -n "$UNHEALTHY_DEPS" ]; then
    echo "### Deployments Não Saudáveis" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    for dep in $UNHEALTHY_DEPS; do
        echo "- \`${dep}\`" >> "$OUTPUT_FILE"
    done
    echo "" >> "$OUTPUT_FILE"
fi

if [ -n "$PROBLEM_PODS" ]; then
    echo "### Pods com Problemas" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    for pod in $PROBLEM_PODS; do
        echo "- \`${pod}\`" >> "$OUTPUT_FILE"
    done
    echo "" >> "$OUTPUT_FILE"
fi

cat >> "$OUTPUT_FILE" << EOF
## Causa Raiz

<!-- Descrever a causa raiz baseada na evidência coletada -->

## Impacto

- **Duração:** <!-- descrever -->
- **Serviços afetados:** <!-- descrever -->
- **Dados perdidos:** <!-- Nenhum / descrever -->

## Ações Corretivas Realizadas

<!-- Comandos ou ações tomadas para resolver -->

## Verificação Pós-Correção

<!-- Como foi verificado que o problema foi resolvido -->

## Lições Aprendidas

1. <!-- Lição 1 -->
2. <!-- Lição 2 -->
3. <!-- Lição 3 -->

## Recomendações

### Imediatas (P0)
- [ ] <!-- Ação imediata -->

### Curto Prazo (P1)
- [ ] <!-- Ação curto prazo -->

### Médio Prazo (P2)
- [ ] <!-- Ação médio prazo -->

## Comandos de Referência

\`\`\`bash
# Verificar status
kubectl get all -n ${NAMESPACE}

# Ver logs
kubectl logs -n ${NAMESPACE} -l app=<app-name> --tail=100

# Ver eventos
kubectl get events -n ${NAMESPACE} --sort-by='.lastTimestamp'
\`\`\`

---
**Autor:** opencode
**Data:** ${DATE}
**Status:** RESOLVIDO
EOF

echo ""
echo "Post-mortem generated: ${OUTPUT_FILE}"
echo "Review and fill in the sections marked with <!-- -->"
