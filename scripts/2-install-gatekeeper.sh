#!/usr/bin/env bash
# =============================================================================
# Script: 2-install-gatekeeper.sh
# Purpose: Install or upgrade Gatekeeper in the cluster and validate webhook
#          readiness for policy enforcement.
#
# Usage:   ./scripts/2-install-gatekeeper.sh
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

GATEKEEPER_NAMESPACE="${GATEKEEPER_NAMESPACE:-gatekeeper-system}"
GATEKEEPER_RELEASE="${GATEKEEPER_RELEASE:-gatekeeper}"
WAIT_TIMEOUT="${WAIT_TIMEOUT:-300s}"
GATEKEEPER_REPLICAS="${GATEKEEPER_REPLICAS:-1}"

print_header "$MAGENTA" "INSTALLING GATEKEEPER"

command -v helm >/dev/null 2>&1 || log_error "helm not found."
command -v kubectl >/dev/null 2>&1 || log_error "kubectl not found."

print_header "$MAGENTA" "1. ADD / UPDATE HELM REPO"
helm repo add gatekeeper https://open-policy-agent.github.io/gatekeeper/charts >/dev/null 2>&1 || true
helm repo update

print_header "$MAGENTA" "2. CREATE NAMESPACE"
kubectl create namespace "${GATEKEEPER_NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -

print_header "$MAGENTA" "3. INSTALL OR UPGRADE GATEKEEPER"
helm upgrade --install "${GATEKEEPER_RELEASE}" gatekeeper/gatekeeper \
  --namespace "${GATEKEEPER_NAMESPACE}" \
  --set replicas="${GATEKEEPER_REPLICAS}"

print_header "$MAGENTA" "4. WAIT FOR PODS"
kubectl -n "${GATEKEEPER_NAMESPACE}" wait --for=condition=Ready pod --all --timeout="${WAIT_TIMEOUT}"

print_header "$TEAL" "5. VALIDATE INSTALLATION"
kubectl -n "${GATEKEEPER_NAMESPACE}" get pods
echo
kubectl get validatingwebhookconfigurations | grep gatekeeper || log_error "Gatekeeper validating webhook not found."

print_header "$MAGENTA" "GATEKEEPER INSTALLATION COMPLETE"
log_info "Gatekeeper is ready."
log_info "Controller replicas: ${GATEKEEPER_REPLICAS}"