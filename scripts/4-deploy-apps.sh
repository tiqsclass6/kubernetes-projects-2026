#!/usr/bin/env bash
# =============================================================================
# Script: 4-deploy-apps.sh
# Purpose: Apply the Argo CD Application manifests for Splunk dev/test/prod and
#          verify that the applications are registered.
#
# Usage:   ./scripts/4-deploy-apps.sh
# =============================================================================

set -euo pipefail
IFS=$'\n\t'

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

HOMEWORK_DIR="${HOMEWORK_DIR:-homework}"
ARGOCD_NAMESPACE="${ARGOCD_NAMESPACE:-argocd}"

APP_PROD="${HOMEWORK_DIR}/30-app-splunk-prod.yaml"
APP_DEV="${HOMEWORK_DIR}/31-app-splunk-dev.yaml"
APP_TEST="${HOMEWORK_DIR}/32-app-splunk-test.yaml"

print_header "$MAGENTA" "DEPLOYING SPLUNK ARGO CD APPLICATIONS"

for f in "$APP_PROD" "$APP_DEV" "$APP_TEST"; do
  [[ -f "$f" ]] || log_error "Required file not found: $f"
done

print_header "$MAGENTA" "1. APPLY PROD APP"
kubectl apply -f "${APP_PROD}"

print_header "$MAGENTA" "2. APPLY DEV APP"
kubectl apply -f "${APP_DEV}"

print_header "$MAGENTA" "3. APPLY TEST APP"
kubectl apply -f "${APP_TEST}"

print_header "$TEAL" "4. VERIFY ARGO CD APPLICATIONS"
kubectl -n "${ARGOCD_NAMESPACE}" get applications || log_error "Unable to list Argo CD applications."

print_header "$MAGENTA" "APPLICATION DEPLOYMENT COMPLETE"
log_info "Splunk Applications submitted to Argo CD."