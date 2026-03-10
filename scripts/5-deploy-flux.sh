#!/usr/bin/env bash
# =============================================================================
# Script: 5-deploy-flux.sh
# Purpose: Trigger Flux reconcile for the Splunk deployment and validate the
#          namespace resources after GitOps sync.
#
# Usage:   ./scripts/5-deploy-flux.sh
# =============================================================================

set -euo pipefail

MAGENTA='\033[0;95m'
TEAL='\033[0;36m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

print_header() {
  local color="$1"
  local text="$2"
  printf "\n${color}══════════════════════════════════════════════════════════════════════${NC}\n"
  printf "${color}  %s${NC}\n" "$text"
  printf "${color}══════════════════════════════════════════════════════════════════════${NC}\n\n"
}

log_info()  { printf "${GREEN}[INFO]${NC}  %s\n" "$*"; }
log_warn()  { printf "${YELLOW}[WARN]${NC}  %s\n" "$*"; }
log_error() { printf "${RED}[ERROR]${NC} %s\n" "$*" >&2; exit 1; }

source "$(dirname "$0")/0-env.sh" >/dev/null

command -v kubectl >/dev/null 2>&1 || log_error "kubectl not found."
command -v flux >/dev/null 2>&1 || log_error "flux CLI not found."

print_header "$MAGENTA" "1. RECONCILE FLUX SOURCE"
if kubectl -n "${FLUX_NAMESPACE}" get gitrepository github-platform >/dev/null 2>&1; then
  flux reconcile source git github-platform -n "${FLUX_NAMESPACE}"
else
  log_warn "GitRepository github-platform not found. Skipping source reconcile."
fi

print_header "$MAGENTA" "2. RECONCILE SPLUNK KUSTOMIZATION"
if kubectl -n "${FLUX_NAMESPACE}" get kustomization splunk-dev >/dev/null 2>&1; then
  flux reconcile kustomization splunk-dev -n "${FLUX_NAMESPACE}" --with-source
else
  log_warn "Kustomization splunk-dev not found. Skipping kustomization reconcile."
fi

print_header "$TEAL" "3. VALIDATE SPLUNK RESOURCES"
kubectl get ns | grep "${SPLUNK_NAMESPACE}" || true
echo
kubectl -n "${SPLUNK_NAMESPACE}" get pods,svc,pvc || true

print_header "$MAGENTA" "SPLUNK DEPLOYMENT STEP COMPLETE"
log_info "Initial reconcile completed."
log_info "Check the Splunk namespace for deployed resources."
log_info "Next step: Monitor Flux sync and Splunk deployment progress."
log_info "Next step: ./scripts/6-install-ingress-cert-manager.sh"