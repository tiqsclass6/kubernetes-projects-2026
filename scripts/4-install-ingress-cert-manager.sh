#!/usr/bin/env bash
# =============================================================================
# Script: 4-install-ingress-cert-manager.sh
# Purpose: Install ingress-nginx and cert-manager (including CRDs) before Flux
#          reconciles GitOps resources that depend on cert-manager APIs.
#
# Usage:   ./scripts/4-install-ingress-cert-manager.sh
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
command -v helm >/dev/null 2>&1 || log_error "helm not found."

print_header "$MAGENTA" "1. VALIDATE CLI DEPENDENCIES"
log_info "kubectl detected."
log_info "helm detected."
log_info "Environment loaded from 0-env.sh"

print_header "$MAGENTA" "2. ADD / REFRESH HELM REPOSITORIES"
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx >/dev/null 2>&1 || true
helm repo add jetstack https://charts.jetstack.io >/dev/null 2>&1 || true
helm repo update
log_info "Helm repositories refreshed."

print_header "$MAGENTA" "3. INSTALL OR UPGRADE INGRESS-NGINX"
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace \
  --wait \
  --timeout 10m

log_info "ingress-nginx release applied."

print_header "$TEAL" "4. WAIT FOR INGRESS-NGINX CONTROLLER READINESS"
kubectl wait \
  --namespace ingress-nginx \
  --for=condition=Available deployment/ingress-nginx-controller \
  --timeout=10m

kubectl -n ingress-nginx get pods
echo
kubectl -n ingress-nginx get svc
log_info "ingress-nginx controller is available."

print_header "$MAGENTA" "5. INSTALL OR UPGRADE CERT-MANAGER WITH CRDS"
helm upgrade --install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --set installCRDs=true \
  --wait \
  --timeout 10m

log_info "cert-manager release applied with CRDs."

print_header "$TEAL" "6. WAIT FOR CERT-MANAGER CRDS TO REGISTER"
CERT_MANAGER_CRDS=(
  certificates.cert-manager.io
  certificaterequests.cert-manager.io
  challenges.acme.cert-manager.io
  clusterissuers.cert-manager.io
  issuers.cert-manager.io
  orders.acme.cert-manager.io
)

for crd in "${CERT_MANAGER_CRDS[@]}"; do
  log_info "Waiting for CRD: ${crd}"
  until kubectl get crd "${crd}" >/dev/null 2>&1; do
    sleep 3
  done
done

kubectl get crd | grep cert-manager || true
log_info "cert-manager CRDs are registered."

print_header "$MAGENTA" "7. WAIT FOR CERT-MANAGER CONTROLLER COMPONENTS"
kubectl wait \
  --namespace cert-manager \
  --for=condition=Available deployment/cert-manager \
  --timeout=10m

kubectl wait \
  --namespace cert-manager \
  --for=condition=Available deployment/cert-manager-webhook \
  --timeout=10m

kubectl wait \
  --namespace cert-manager \
  --for=condition=Available deployment/cert-manager-cainjector \
  --timeout=10m

kubectl -n cert-manager get pods
log_info "cert-manager controller, webhook, and cainjector are available."

print_header "$TEAL" "8. VERIFY CERT-MANAGER APIS ARE SERVED"
kubectl api-resources | grep -E 'clusterissuers|issuers|certificates' || \
  log_error "cert-manager API resources are not available."

kubectl get clusterissuer >/dev/null 2>&1 || true
log_info "cert-manager API discovery check passed."

print_header "$MAGENTA" "9. PREREQUISITE INSTALLATION COMPLETE"
log_info "ingress-nginx installed and validated."
log_info "cert-manager installed with CRDs and validated."
log_info "Flux can now safely reconcile ClusterIssuer / Certificate resources."
log_info "Next step: ./scripts/5-apply-flux.sh"