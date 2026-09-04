---
name: incident-response
description: >
  Incident response and troubleshooting for Kubernetes/AKS clusters. Investigates pod failures, deployment issues, service outages, and generates post-mortem documents. USE WHEN: user reports service down, pod crash, deployment failed, pods not running, connection refused, image pull errors, readiness/liveness probe failures, Kubernetes errors, AKS issues, or asks to investigate why something isn't working in k8s. Triggers on keywords like "fora do ar", "down", "crashed", "error", "incident", "investigate", "why isn't working", "pod failed", "deploy failed". ALWAYS USE for Kubernetes incident investigation and post-mortem generation.
---

# Incident Response Skill

Investigate and resolve Kubernetes/AKS incidents systematically. Never guess — gather evidence first.

## Workflow

### Phase 1: Triage (30 seconds)

Run these commands in parallel to get immediate situational awareness:

```bash
# Namespace status
kubectl get ns <namespace> 2>&1

# All resources in namespace
kubectl get all -n <namespace> 2>&1

# Recent events (sorted by time)
kubectl get events -n <namespace> --sort-by='.lastTimestamp' 2>&1 | tail -30
```

Identify: Which component is affected? Is it a pod, deployment, service, or ingress?

### Phase 2: Deep Investigation

Based on triage findings, investigate the specific failure type:

#### Pods not Running / CrashLoopBackOff

```bash
# Pod details
kubectl describe pod <pod-name> -n <namespace>

# Pod logs (current and previous)
kubectl logs <pod-name> -n <namespace> --tail=100
kubectl logs <pod-name> -n <namespace> --previous --tail=50

# Resource usage
kubectl top pod -n <namespace>
```

**Common causes:**
- `ImagePullBackOff`: Image tag doesn't exist or registry auth issue
- `CrashLoopBackOff`: App crashes on startup (check logs)
- `OOMKilled`: Memory limit too low
- `ErrImagePull`: Registry unreachable or auth failed

#### Deployment Issues (0/0 replicas, scaling problems)

```bash
# Deployment status
kubectl describe deployment <name> -n <namespace>

# ReplicaSet status
kubectl get rs -n <namespace> -o wide

# Rollout history
kubectl rollout history deployment/<name> -n <namespace>
```

**Common causes:**
- Replicas set to 0 (manual scale or bad deploy)
- Image doesn't exist (new ReplicaSet never becomes ready)
- Readiness probe failing (pod never becomes ready)

#### Service / Connectivity Issues

```bash
# Service endpoints
kubectl get svc <name> -n <namespace> -o yaml

# Endpoints (are pods actually registered?)
kubectl get endpoints <name> -n <namespace>

# Test connectivity from inside cluster
kubectl exec -n <namespace> <pod-name> -- wget -qO- http://<service>:<port>/<path>
```

**Common causes:**
- No endpoints (selector doesn't match pod labels)
- Port mismatch between service and container
- Network policy blocking traffic

#### Node-Level Issues

```bash
# Node status
kubectl get nodes -o wide

# Node resources
kubectl describe node <node-name> | grep -A 5 "Allocated resources"

# Pods on specific node
kubectl get pods -n <namespace> --field-selector spec.nodeName=<node-name>
```

### Phase 3: Root Cause Analysis

After gathering evidence, identify the root cause:

1. **Timeline reconstruction**: When did the issue start? What changed?
2. **Correlation**: Did a deploy, scale event, or config change precede the failure?
3. **Impact scope**: Single pod, all replicas, entire service, multiple services?

### Phase 4: Resolution

Apply the fix based on root cause:

| Root Cause | Resolution |
|------------|------------|
| 0 replicas | `kubectl scale deployment <name> -n <ns> --replicas=N` |
| Bad image | `kubectl set image deployment/<name> <container>=<correct-image> -n <ns>` |
| CrashLoopBackOff | Fix app code/config, then restart |
| OOMKilled | Increase memory limits in deployment spec |
| Probe failure | Fix probe config or the app endpoint it checks |
| Service selector mismatch | Fix service selector to match pod labels |

**IMPORTANT**: Do NOT apply fixes without user confirmation. Present findings and wait for approval.

### Phase 5: Post-Mortem

After resolution, generate a post-mortem document. Use the template at `templates/POST_MORTEM_TEMPLATE.md`.

Save to `docs/POST_MORTEM_YYYY-MM-DD.md` in the project repository.

## Quick Reference: Common kubectl Debug Commands

```bash
# Full resource view
kubectl get all -n <ns> -o wide

# YAML inspection
kubectl get deployment <name> -n <ns> -o yaml

# Live pod logs
kubectl logs -f <pod-name> -n <ns>

# Execute inside pod
kubectl exec -it <pod-name> -n <ns> -- /bin/sh

# Force delete stuck pod
kubectl delete pod <pod-name> -n <ns> --force --grace-period=0

# Rollback deployment
kubectl rollout undo deployment/<name> -n <ns>
```

## Output Format

Always present findings in this structure:

```
## [Component] - [Status]

### Problema
<1-2 sentence description>

### Causa Raiz
<Evidence-based root cause>

### Impacto
<Duration, affected services, users>

### Correção
<Command or action taken>

### Validação
<Proof that the fix worked>
```
