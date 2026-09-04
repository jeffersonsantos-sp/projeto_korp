# Kubernetes Incident Response - Quick Reference

## Pod States and Meanings

| State | Meaning | Common Fix |
|-------|---------|------------|
| `Running` | Pod is running | None (check readiness) |
| `Pending` | Waiting to be scheduled | Check node resources, PVC |
| `Succeeded` | Completed (jobs) | None |
| `Failed` | Terminated with error | Check logs |
| `CrashLoopBackOff` | Crashing repeatedly | Check logs, fix app |
| `ImagePullBackOff` | Can't pull image | Fix image tag or registry auth |
| `ErrImagePull` | Image pull error | Check image name and registry |
| `OOMKilled` | Out of memory | Increase memory limits |
| `Terminating` | Being deleted | Wait or force delete |
| `Unknown` | Node lost contact | Check node status |

## Container Status Codes

| Exit Code | Meaning |
|-----------|---------|
| 0 | Normal exit (success) |
| 1 | Application error |
| 126 | Permission denied |
| 127 | Command not found |
| 137 | SIGKILL (OOM or manual kill) |
| 139 | Segmentation fault |
| 143 | SIGTERM (graceful stop) |

## Common kubectl Debug Commands

```bash
# Pod debugging
kubectl describe pod <pod> -n <ns>
kubectl logs <pod> -n <ns> --tail=100
kubectl logs <pod> -n <ns> --previous
kubectl exec -it <pod> -n <ns> -- /bin/sh
kubectl top pod -n <ns>

# Deployment debugging
kubectl describe deployment <name> -n <ns>
kubectl rollout status deployment/<name> -n <ns>
kubectl rollout history deployment/<name> -n <ns>
kubectl rollout undo deployment/<name> -n <ns>

# Service debugging
kubectl describe svc <name> -n <ns>
kubectl get endpoints <name> -n <ns>
kubectl exec -n <ns> <pod> -- wget -qO- http://<svc>:<port>

# Node debugging
kubectl get nodes -o wide
kubectl describe node <node>
kubectl top node
kubectl get pods -n <ns> --field-selector spec.nodeName=<node>

# Network debugging
kubectl get networkpolicy -n <ns>
kubectl get ingress -n <ns>
kubectl describe ingress <name> -n <ns>
```

## Incident Severity Levels

| Level | Description | Response Time |
|-------|-------------|---------------|
| SEV1 | Complete service outage | Immediate |
| SEV2 | Major feature broken, no workaround | < 1 hour |
| SEV3 | Major feature broken, workaround exists | < 4 hours |
| SEV4 | Minor issue, low impact | Next business day |

## Post-Mortem Checklist

- [ ] Timeline documented
- [ ] Root cause identified
- [ ] Impact quantified
- [ ] Resolution steps recorded
- [ ] Verification performed
- [ ] Lessons learned captured
- [ ] Action items assigned
- [ ] Follow-up scheduled
