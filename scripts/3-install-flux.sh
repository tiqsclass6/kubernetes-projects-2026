#!/usr/bin/env bash
# =============================================================================
# Script: 3-install-flux.sh
# Purpose: Install Flux controllers into the target GKE cluster and validate
#          controller readiness.
#
# Usage:   ./scripts/3-install-flux.sh
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

print_header "$MAGENTA" "1. INSTALL FLUX CONTROLLERS"
kubectl apply -f https://github.com/fluxcd/flux2/releases/latest/download/install.yaml

print_header "$MAGENTA" "2. WAIT FOR FLUX CONTROLLERS"
kubectl -n "${FLUX_NAMESPACE}" rollout status deployment/source-controller --timeout=300s
kubectl -n "${FLUX_NAMESPACE}" rollout status deployment/kustomize-controller --timeout=300s
kubectl -n "${FLUX_NAMESPACE}" rollout status deployment/helm-controller --timeout=300s
kubectl -n "${FLUX_NAMESPACE}" rollout status deployment/notification-controller --timeout=300s

print_header "$TEAL" "3. VALIDATE FLUX INSTALLATION"
kubectl -n "${FLUX_NAMESPACE}" get pods
echo
flux check

print_header "$MAGENTA" "FLUX INSTALLATION COMPLETE"
log_info "Flux controllers are ready."
log_info "Next step: ./scripts/4-apply-flux.sh"