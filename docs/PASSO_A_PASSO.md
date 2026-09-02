# Guia Rapido - Apresentacao

## Comandos Principais

### 1. Deletar Namespace
```bash
kubectl delete namespace projeto-korp
```

### 2. Rodar Ansible (Deploy Completo)
```bash
cd ~/Desktop/projeto_korp/ansible
~/ansible-venv/bin/ansible-playbook -i inventory.ini playbook-aks.yml
```

### 3. Verificar Deploy
```bash
kubectl get pods -n projeto-korp
kubectl get svc -n projeto-korp
```

### 4. Testar API
```bash
curl http://$(kubectl get svc nginx -n projeto-korp -o jsonpath='{.status.loadBalancer.ingress[0].ip}')/projeto-korp
```

### 5. Acessar Grafana
```bash
kubectl port-forward -n projeto-korp svc/grafana 3000:3000
```
Acesse: http://localhost:3000
Login: admin/admin (trocar no primeiro acesso)

### 6. Acessar Prometheus
```bash
kubectl port-forward -n projeto-korp svc/prometheus 9090:9090
```
Acesse: http://localhost:9090

---

## CI/CD (Git)

### Commit
```bash
git add .
git commit -m "Descricao da alteracao"
git push
```

### Tag (dispara CI/CD)
```bash
git tag v2.0.0
git push origin v2.0.0
```

### Verificar Actions
https://github.com/jeffersonsantos-sp/projeto_korp/actions

---

## Ordem da Apresentacao

1. Deletar namespace
2. Rodar Ansible
3. Mostrar pods rodando
4. Testar API (curl)
5. Abrir Grafana
6. Abrir Prometheus
7. Explicar arquitetura
8. Explicar CI/CD
