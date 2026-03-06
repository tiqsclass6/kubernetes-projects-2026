#!/usr/bin/env bash
# =============================================================================
# Script: deployment.sh
# Purpose: Install official stable Argo CD (using Server-Side Apply) + custom RBAC
#          + Splunk Application resources for security lab / educational use
#
# Usage:   ./deployment.sh    (run from directory containing 'manifests/')
# =============================================================================

set -euo pipefail
IFS=$'\n\t'

# ──────────────────────────────────────────────────────────────────────────────
# Configuration
# ──────────────────────────────────────────────────────────────────────────────

NAMESPACE="argocd"
MANIFESTS_DIR="manifests"
RBAC_DIR="${MANIFESTS_DIR}/rbac"

EXPECTED_APP_REPO="https://github.com/tiqsclass6/kubernetes-projects-2026.git"

RBAC_FILE="argocd-rbac-cm.yaml"

SPLUNK_FILES=(
  "splunk-app.yaml"
  "splunk-dev-app.yaml"
  "splunk-test-app.yaml"
)

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# ──────────────────────────────────────────────────────────────────────────────
# Helpers
# ──────────────────────────────────────────────────────────────────────────────

log_info()  { printf "${GREEN}[INFO]${NC}  %s\n" "$*"; }
log_warn()  { printf "${YELLOW}[WARN]${NC}  %s\n" "$*"; }
log_error() { printf "${RED}[ERROR]${NC} %s\n" "$*" >&2; exit 1; }

check_file_exists() {
  local path="$1"
  [[ -f "$path" ]] || log_error "Required file not found: $path"
}

wait_for_pods_ready() {
  local ns="$1"
  local timeout=300
  log_info "Waiting for pods in namespace '${ns}' to become Ready (timeout: ${timeout}s)..."
  if ! kubectl -n "${ns}" wait --for=condition=Ready pod --all --timeout="${timeout}s"; then
    log_error "Timeout waiting for pods in '${ns}'"
  fi
  log_info "All pods in '${ns}' are Ready."
}

# ──────────────────────────────────────────────────────────────────────────────
# Main
# ──────────────────────────────────────────────────────────────────────────────

log_info "Starting Argo CD deployment (official + custom RBAC)"

# 1. Validate files
check_file_exists "${RBAC_DIR}/${RBAC_FILE}"
for f in "${SPLUNK_FILES[@]}"; do
  [[ -f "${MANIFESTS_DIR}/${f}" ]] && log_info "Found: ${f}" || log_warn "Skipped (not found): ${f}"
done

# 2. Install official Argo CD with Server-Side Apply
log_info "Creating namespace '${NAMESPACE}' if needed..."
kubectl create namespace "${NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -

log_info "Installing official stable Argo CD (using Server-Side Apply)..."
kubectl apply -n "${NAMESPACE}" -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml \
  --server-side --force-conflicts

# 3. Wait for readiness
wait_for_pods_ready "${NAMESPACE}"

# 4. Apply & reload custom RBAC
log_info "Applying custom RBAC..."
kubectl apply -f "${RBAC_DIR}/${RBAC_FILE}"

log_info "Restarting argocd-server to load new RBAC..."
kubectl -n "${NAMESPACE}" rollout restart deployment argocd-server
kubectl -n "${NAMESPACE}" rollout status deployment argocd-server --timeout=120s

# 5. Verification
log_info "Pods in ${NAMESPACE}:"
kubectl -n "${NAMESPACE}" get pods -o wide

log_info "Current Applications:"
kubectl -n "${NAMESPACE}" get applications 2>/dev/null || echo "(none yet)"

# 6. UI access instructions
log_info "Argo CD UI:"
log_info "  kubectl -n ${NAMESPACE} port-forward svc/argocd-server 8080:443"
log_info "  Open: https://localhost:8080 (accept self-signed cert warning)"
log_info "Credentials:"
log_info "  Username: admin"
echo "  Password: kubectl -n ${NAMESPACE} get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 --decode; echo"

# 7. Apply Splunk apps
log_info "Applying Splunk manifests (repo: ${EXPECTED_APP_REPO})..."

applied=false
for f in "${SPLUNK_FILES[@]}"; do
  p="${MANIFESTS_DIR}/${f}"
  if [[ -f "$p" ]]; then
    log_info "Applying ${f}..."
    kubectl apply -f "$p" || log_error "Apply failed: ${f}"
    applied=true
  else
    log_warn "Skipped (missing): ${f}"
  fi
done

if [[ "$applied" == true ]]; then
  log_info "Applications:"
  kubectl -n "${NAMESPACE}" get applications

  log_info "Waiting for initial sync/namespace creation..."
  sleep 15

  for ns in splunk splunk-dev splunk-test; do
    if kubectl get ns "$ns" &>/dev/null; then
      log_info "Resources in '${ns}':"
      kubectl -n "$ns" get pods,svc,pvc --ignore-not-found
    else
      log_warn "Namespace '${ns}' not yet created (sync may be pending)."
    fi
  done

  log_info "Sync command (after login):"
  echo "  argocd app sync splunk splunk-dev splunk-test"
else
  log_warn "No Splunk manifests applied."
fi

log_info "Deployment complete."
log_info "Next:"
echo "  • Get password (above)"
echo "  • Log in to UI"
echo "  • Sync applications"
echo "  • Test RBAC with different roles"