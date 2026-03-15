#!/usr/bin/env bash
# =============================================================================
# Script: 7-reconcile-and-verify.sh
# Purpose: Perform day-2 verification of Flux controllers, Git sources,
#          kustomizations, and Splunk resources.
#
# Usage:   ./scripts/7-reconcile-and-verify.sh
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

print_header "$MAGENTA" "1. FLUX CONTROLLERS"
kubectl -n "${FLUX_NAMESPACE}" get pods

print_header "$MAGENTA" "2. FLUX GIT SOURCES"
flux get sources git -A || true
kubectl -n "${FLUX_NAMESPACE}" describe gitrepository github-platform || true

print_header "$MAGENTA" "3. FLUX KUSTOMIZATIONS"
flux get kustomizations -A || true
kubectl -n "${FLUX_NAMESPACE}" describe kustomization splunk-dev || true

print_header "$MAGENTA" "4. SPLUNK RESOURCES"
kubectl -n "${SPLUNK_NAMESPACE}" get all || true
echo
kubectl -n "${SPLUNK_NAMESPACE}" get pvc || true
echo
kubectl -n "${SPLUNK_NAMESPACE}" describe pod splunk-0 || true

print_header "$TEAL" "5. RECENT FLUX TROUBLESHOOTING LOGS"
kubectl -n "${FLUX_NAMESPACE}" logs deploy/source-controller --tail=200 || true
echo
kubectl -n "${FLUX_NAMESPACE}" logs deploy/kustomize-controller --tail=200 || true

print_header "$TEAL" "6. SPLUNK TROUBLESHOOTING LOGS"
kubectl -n "${SPLUNK_NAMESPACE}" logs splunk-0 || true

print_header "$MAGENTA" "VERIFICATION COMPLETE"
log_info "Review the output above for readiness, sync status, and errors."
log_info "Next step: ./scripts/8-teardown.sh"