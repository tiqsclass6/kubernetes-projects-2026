#!/usr/bin/env bash
# =============================================================================
# Script: deploy-argocd-security-lab.sh
# Purpose: Deploy minimal Argo CD + RBAC configuration + optional Splunk apps
#          based on the homework file structure under manifests/
# Usage:   ./deploy-argocd-security-lab.sh    (run from the directory containing 'manifests/')
# =============================================================================

set -euo pipefail
IFS=$'\n\t'

# ──────────────────────────────────────────────────────────────────────────────
# Configuration
# ──────────────────────────────────────────────────────────────────────────────

MANIFESTS_DIR="manifests"
RBAC_DIR="${MANIFESTS_DIR}/rbac"

NAMESPACE="argocd"

# Core Argo CD component files (apply order matters)
CORE_FILES=(
  "argocd-namespace.yaml"
  "argocd-deploy.yaml"
  "argocd-repo.yaml"
  "argocd-controller.yaml"
  "argocd-port.yaml"
)

# RBAC ConfigMap (applied right after core components)
RBAC_FILE="argocd-rbac-cm.yaml"

# Optional Splunk-related Argo CD Application manifests
SPLUNK_FILES=(
  "splunk-app.yaml"
  "splunk-dev-app.yaml"
  "splunk-test-app.yaml"
)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# ──────────────────────────────────────────────────────────────────────────────
# Helper Functions
# ──────────────────────────────────────────────────────────────────────────────

log_info()  { printf "${GREEN}[INFO]${NC}  %s\n" "$*"; }
log_warn()  { printf "${YELLOW}[WARN]${NC}  %s\n" "$*"; }
log_error() { printf "${RED}[ERROR]${NC} %s\n" "$*" >&2; exit 1; }

check_file_exists() {
  local file="$1"
  local fullpath="$2"
  [[ -f "$fullpath" ]] || log_error "Required file not found: $fullpath"
}

wait_for_pods_ready() {
  local namespace="$1"
  local timeout=180
  local interval=10
  local elapsed=0

  log_info "Waiting for all pods in namespace '$namespace' to become Ready (timeout: ${timeout}s)..."

  while [ $elapsed -lt $timeout ]; do
    if kubectl -n "$namespace" wait --for=condition=Ready pod --all --timeout=0s &>/dev/null; then
      log_info "All pods in namespace '$namespace' are Ready."
      return 0
    fi
    sleep "$interval"
    elapsed=$((elapsed + interval))
    printf "."
  done
  log_error "Timeout waiting for pods to become ready in namespace '$namespace'"
}

# ──────────────────────────────────────────────────────────────────────────────
# Main Logic
# ──────────────────────────────────────────────────────────────────────────────

log_info "Starting Argo CD deployment with RBAC (security lab variant)..."

if [[ ! -d "$MANIFESTS_DIR" ]]; then
  log_error "Directory '${MANIFESTS_DIR}' not found. Please run this script from the parent directory."
fi

# 1. Validate core files
for file in "${CORE_FILES[@]}"; do
  check_file_exists "$file" "${MANIFESTS_DIR}/${file}"
done

# Validate RBAC file
check_file_exists "$RBAC_FILE" "${RBAC_DIR}/${RBAC_FILE}"

# 2. Apply core Argo CD components
log_info "Applying core Argo CD components from ${MANIFESTS_DIR}/ ..."

for file in "${CORE_FILES[@]}"; do
  fullpath="${MANIFESTS_DIR}/${file}"
  log_info "Applying $file ..."
  kubectl apply -f "$fullpath" || log_error "Failed to apply $fullpath"
done

# 3. Apply RBAC ConfigMap
rbac_fullpath="${RBAC_DIR}/${RBAC_FILE}"
log_info "Applying RBAC configuration: $RBAC_FILE ..."
kubectl apply -f "$rbac_fullpath" || log_error "Failed to apply $rbac_fullpath"

# 4. Wait for Argo CD pods to become ready
wait_for_pods_ready "$NAMESPACE"

# 5. Show verification output
log_info "Verification — Pods in namespace ${NAMESPACE}:"
kubectl -n "$NAMESPACE" get pods -o wide

log_info "Verification — Services in namespace ${NAMESPACE}:"
kubectl -n "$NAMESPACE" get svc

log_info "Verification — ConfigMaps in namespace ${NAMESPACE} (RBAC):"
kubectl -n "$NAMESPACE" get configmap argocd-rbac-cm -o yaml --show-managed-fields=false

# 6. Provide access instructions
log_info "Argo CD UI Access Options:"

log_info "NodePort access (port 30081):"
kubectl get nodes -o wide | grep -v '^NAME' | awk '{print "  http://" $6 ":30081"}'
echo "  (use any listed INTERNAL-IP or EXTERNAL-IP)"

log_info "Port-forward access (recommended for local/lab usage):"
echo "  kubectl -n ${NAMESPACE} port-forward svc/argocd-server 9081:9081 &"
echo "  Then open in browser: http://localhost:9081"

log_info "Initial credentials:"
echo "  Username: admin"
echo "  Password: Retrieve with:"
echo "    kubectl -n ${NAMESPACE} get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 --decode; echo"

# 7. Optional: Deploy Splunk-related Applications
log_info "Applying available Splunk Application manifests..."

applied_splunk=false
for file in "${SPLUNK_FILES[@]}"; do
  fullpath="${MANIFESTS_DIR}/${file}"
  if [[ -f "$fullpath" ]]; then
    log_info "Applying $file ..."
    kubectl apply -f "$fullpath" || log_error "Failed to apply $fullpath"
    applied_splunk=true
  else
    log_warn "File not found (skipping): $fullpath"
  fi
done

if [[ "$applied_splunk" == true ]]; then
  log_info "Verification — Argo CD Applications:"
  kubectl -n "$NAMESPACE" get applications

  log_info "Waiting briefly for namespace(s) creation / initial sync..."
  sleep 12

  for ns in splunk splunk-dev; do
    if kubectl get namespace "$ns" &>/dev/null; then
      log_info "Resources in namespace '$ns' (may still be provisioning):"
      kubectl -n "$ns" get pods,svc,pvc --ignore-not-found
    else
      log_warn "Namespace '$ns' does not yet exist."
    fi
  done
else
  log_warn "No Splunk Application manifests were applied."
fi

log_info "Deployment completed successfully."
log_info "Next recommended steps:"
echo "  • Retrieve the admin password (command shown above)"
echo "  • Log in to the UI and verify RBAC behavior with different user groups"
echo "  • Review argocd-rbac-cm.yaml to understand role bindings"
echo "  • Consider adding TLS and removing --insecure for non-lab environments"