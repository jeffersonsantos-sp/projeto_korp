#!/bin/bash
# incident-investigate.sh - Automated incident investigation for Kubernetes
# Usage: ./incident-investigate.sh <namespace> [deployment-name]

set -e

NAMESPACE=${1:?"Usage: $0 <namespace> [deployment-name]"}
DEPLOYMENT=$2
TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
REPORT_DIR="/tmp/incident-${NAMESPACE}-${TIMESTAMP}"

mkdir -p "$REPORT_DIR"

echo "========================================="
echo "INCIDENT INVESTIGATION - $(date)"
echo "Namespace: $NAMESPACE"
echo "========================================="

# Phase 1: Triage
echo ""
echo "[PHASE 1] TRIAGE"
echo "----------------"

echo ""
echo "=== Namespace Status ==="
kubectl get ns "$NAMESPACE" 2>&1 | tee "$REPORT_DIR/namespace.txt"

echo ""
echo "=== All Resources ==="
kubectl get all -n "$NAMESPACE" -o wide 2>&1 | tee "$REPORT_DIR/all-resources.txt"

echo ""
echo "=== Recent Events ==="
kubectl get events -n "$NAMESPACE" --sort-by='.lastTimestamp' 2>&1 | tail -30 | tee "$REPORT_DIR/events.txt"

# Phase 2: Component Deep Dive
echo ""
echo "[PHASE 2] DEEP INVESTIGATION"
echo "-----------------------------"

# Check deployments
echo ""
echo "=== Deployments ==="
kubectl get deployments -n "$NAMESPACE" -o wide 2>&1 | tee "$REPORT_DIR/deployments.txt"

# Check for unhealthy deployments
UNHEALTHY_DEPS=$(kubectl get deployments -n "$NAMESPACE" -o json | \
  jq -r '.items[] | select(.status.availableReplicas == 0 or .status.availableReplicas == null) | .metadata.name' 2>/dev/null)

if [ -n "$UNHEALTHY_DEPS" ]; then
    echo ""
    echo "!!! UNHEALTHY DEPLOYMENTS FOUND !!!"
    for dep in $UNHEALTHY_DEPS; do
        echo ""
        echo "--- Deployment: $dep ---"
        kubectl describe deployment "$dep" -n "$NAMESPACE" 2>&1 | tee "$REPORT_DIR/deploy-${dep}.txt"
    done
fi

# Check pods
echo ""
echo "=== Pods Status ==="
kubectl get pods -n "$NAMESPACE" -o wide 2>&1 | tee "$REPORT_DIR/pods.txt"

# Check for problem pods
PROBLEM_PODS=$(kubectl get pods -n "$NAMESPACE" -o json | \
  jq -r '.items[] | select(.status.phase != "Running" or (.status.containerStatuses[]? | select(.ready == false))) | .metadata.name' 2>/dev/null | sort -u)

if [ -n "$PROBLEM_PODS" ]; then
    echo ""
    echo "!!! PROBLEM PODS FOUND !!!"
    for pod in $PROBLEM_PODS; do
        echo ""
        echo "--- Pod: $pod ---"
        kubectl describe pod "$pod" -n "$NAMESPACE" 2>&1 | tee "$REPORT_DIR/pod-${pod}.txt"
        echo ""
        echo "--- Logs: $pod ---"
        kubectl logs "$pod" -n "$NAMESPACE" --tail=50 2>&1 | tee "$REPORT_DIR/pod-${pod}-logs.txt"
        echo ""
        echo "--- Previous Logs: $pod ---"
        kubectl logs "$pod" -n "$NAMESPACE" --previous --tail=30 2>&1 | tee "$REPORT_DIR/pod-${pod}-prev-logs.txt" 2>/dev/null || echo "(no previous logs)"
    done
fi

# Check ReplicaSets
echo ""
echo "=== ReplicaSets ==="
kubectl get rs -n "$NAMESPACE" -o wide 2>&1 | tee "$REPORT_DIR/replicasets.txt"

# Check services
echo ""
echo "=== Services ==="
kubectl get svc -n "$NAMESPACE" -o wide 2>&1 | tee "$REPORT_DIR/services.txt"

# Check endpoints
echo ""
echo "=== Endpoints ==="
kubectl get endpoints -n "$NAMESPACE" -o wide 2>&1 | tee "$REPORT_DIR/endpoints.txt"

# Phase 3: If specific deployment requested
if [ -n "$DEPLOYMENT" ]; then
    echo ""
    echo "[PHASE 3] DEPLOYMENT SPECIFIC: $DEPLOYMENT"
    echo "------------------------------------------"
    
    kubectl describe deployment "$DEPLOYMENT" -n "$NAMESPACE" 2>&1 | tee "$REPORT_DIR/deploy-detail-${DEPLOYMENT}.txt"
    
    echo ""
    echo "=== Rollout History ==="
    kubectl rollout history deployment/"$DEPLOYMENT" -n "$NAMESPACE" 2>&1 | tee "$REPORT_DIR/rollout-history-${DEPLOYMENT}.txt"
    
    echo ""
    echo "=== Deployment YAML ==="
    kubectl get deployment "$DEPLOYMENT" -n "$NAMESPACE" -o yaml 2>&1 | tee "$REPORT_DIR/deploy-yaml-${DEPLOYMENT}.txt"
fi

# Summary
echo ""
echo "========================================="
echo "INVESTIGATION COMPLETE"
echo "Report saved to: $REPORT_DIR"
echo "========================================="
echo ""
echo "Files generated:"
ls -la "$REPORT_DIR"
