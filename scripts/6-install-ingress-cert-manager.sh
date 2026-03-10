#!/usr/bin/env bash
# =============================================================================
# Script: 6-install-ingress-cert-manager.sh
# Purpose: Install ingress-nginx and cert-manager for optional ingress and TLS
#          support for the Splunk deployment.
#
# Usage:   ./scripts/6-install-ingress-cert-manager.sh
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

print_header "$MAGENTA" "1. INSTALL INGRESS-NGINX"
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml
kubectl -n ingress-nginx rollout status deployment/ingress-nginx-controller --timeout=300s

print_header "$MAGENTA" "2. INSTALL CERT-MANAGER"
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.yaml
kubectl -n cert-manager rollout status deployment/cert-manager --timeout=300s
kubectl -n cert-manager rollout status deployment/cert-manager-webhook --timeout=300s
kubectl -n cert-manager rollout status deployment/cert-manager-cainjector --timeout=300s

print_header "$TEAL" "3. VALIDATE OPTIONAL COMPONENTS"
kubectl -n ingress-nginx get pods
echo
kubectl -n cert-manager get pods

print_header "$MAGENTA" "INGRESS AND CERT-MANAGER INSTALL COMPLETE"
log_info "Optional ingress and TLS dependencies are ready."
log_info "Next step: ./scripts/7-reconcile-and-verify.sh"