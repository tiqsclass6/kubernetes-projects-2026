#!/usr/bin/env bash
# =============================================================================
# Script: 4-apply-flux.sh
# Purpose: Apply the Flux GitRepository and Kustomization manifests for the
#          selected Git provider.
#
# Usage:   ./scripts/4-apply-flux.sh
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

print_header "$MAGENTA" "1. APPLY FLUX SOURCE MANIFESTS"

case "${GIT_PROVIDER}" in
  github)
    kubectl apply -f "${LAB_GITHUB_DIR}/01-gitrepository.yaml"
    kubectl apply -f "${LAB_GITHUB_DIR}/02-kustomization-splunk-dev.yaml"
    ;;
  bitbucket)
    kubectl apply -f "${FLUX_DIR}/bitbucket_gitsource.yaml"
    kubectl apply -f "${FLUX_DIR}/splunk_kustomization.yaml"
    ;;
  ado)
    kubectl apply -f "${FLUX_DIR}/ADO_gitsource.yaml"
    kubectl apply -f "${FLUX_DIR}/splunk_kustomization.yaml"
    ;;
  *)
    log_error "Unsupported GIT_PROVIDER=${GIT_PROVIDER}"
    ;;
esac

print_header "$TEAL" "2. VERIFY GIT SOURCE"
flux get sources git -A || true
kubectl -n "${FLUX_NAMESPACE}" describe gitrepository github-platform || true

print_header "$TEAL" "3. VERIFY KUSTOMIZATION"
flux get kustomizations -A || true
kubectl -n "${FLUX_NAMESPACE}" describe kustomization splunk-dev || true

print_header "$MAGENTA" "FLUX SOURCE APPLY COMPLETE"
log_info "Flux source manifests were applied."
log_info "If the folder does not exist in Git yet, Flux may report an error until the repo structure is pushed."
log_info "Next step: ./scripts/5-deploy-flux.sh"