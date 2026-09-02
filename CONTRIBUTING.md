# Contribuindo com o Projeto

## Fluxo de Trabalho

### 1. Criar Feature Branch

```bash
# Sempre criar branch a partir do main
git checkout main
git pull

# Criar feature
git checkout -b feature/nome-da-feature

# Exemplos:
git checkout -b feature/adicionar-alertas
git checkout -b feature/melhorar-dashboard
git checkout -b fix/corrigir-health-check
git checkout -b docs/atualizar-readme
```

### 2. Trabalhar na Feature

```bash
# Fazer alteracoes
git add .
git commit -m "Descricao clara da alteracao"

# Push da feature
git push origin feature/nome-da-feature
```

### 3. Criar Pull Request

1. Acesse: `https://github.com/jeffersonsantos-sp/projeto_korp/pulls`
2. Clique em **"New pull request"**
3. Selecione:
   - **Base:** `main`
   - **Compare:** `feature/nome-da-feature`
4. Preencha:
   - **Title:** Descricao clara
   - **Description:** O que foi feito e por que
5. Clique em **"Create pull request"**

### 4. Code Review

1. Adicione reviewers (se tiver equipe)
2. Aguarde aprovacao
3. Verifique se os checks passaram (CI/CD)
4. Apos aprovacao, faca merge

### 5. Apos o Merge

```bash
# Voltar para main
git checkout main
git pull

# Deletar feature branch (local)
git branch -d feature/nome-da-feature

# Deletar feature branch (remota)
git push origin --delete feature/nome-da-feature
```

## Nomenclatura de Branches

| Tipo | Prefixo | Exemplo |
|------|---------|---------|
| Feature | `feature/` | `feature/adicionar-cache` |
| Bugfix | `fix/` | `fix/corrigir-rota` |
| Hotfix | `hotfix/` | `hotfix/corrigir-seguranca` |
| Docs | `docs/` | `docs/atualizar-api` |
| Refactor | `refactor/` | `refactor/melhorar-codigo` |

## Commits

### Formato
```
<tipo>: <descricao curta>

<descricao opcional>
```

### Tipos
- `feat:` Nova funcionalidade
- `fix:` Correcao de bug
- `docs:` Documentacao
- `style:` Formatacao
- `refactor:` Refatoracao
- `test:` Testes
- `chore:` Tarefas administrativas

### Exemplos
```bash
git commit -m "feat: adicionar metrica de memoria"
git commit -m "fix: corrigir health check do NGINX"
git commit -m "docs: atualizar README com novos endpoints"
```

## Pull Request Template

```markdown
## Descricao
Breve descricao do que foi feito

## Tipo de Mudanca
- [ ] Nova funcionalidade
- [ ] Correcao de bug
- [ ] Melhoria
- [ ] Documentacao

## Como Testar
1. Passo 1
2. Passo 2
3. Passo 3

## Screenshots (se aplicavel)
```

## Protecao da Branch Main

A branch `main` deve ter protecao configurada:

1. Acesse: `https://github.com/jeffersonsantos-sp/projeto_korp/settings/branches`
2. Clique em **"Add rule"**
3. Configure:
   - **Branch name pattern:** `main`
   - ✅ **Require pull request before merging**
   - ✅ **Require approvals:** 1
   - ✅ **Require status checks to pass**
   - ✅ **Require branches to be up to date**
4. Clique em **"Create"**
