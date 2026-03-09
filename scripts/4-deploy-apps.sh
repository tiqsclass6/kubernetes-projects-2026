#!/usr/bin/env bash
# =============================================================================
# Script: 4-deploy-apps.sh
# Purpose: Install Argo CD if needed, then apply the Argo CD Application
#          manifests for Splunk dev/test/prod and verify registration.
#
# Usage:   ./scripts/4-deploy-apps.sh
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

HOMEWORK_DIR="${HOMEWORK_DIR:-homework}"
ARGOCD_NAMESPACE="${ARGOCD_NAMESPACE:-argocd}"
ARGOCD_INSTALL_URL="${ARGOCD_INSTALL_URL:-https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml}"

APP_PROD="${HOMEWORK_DIR}/30-app-splunk-prod.yaml"
APP_DEV="${HOMEWORK_DIR}/31-app-splunk-dev.yaml"
APP_TEST="${HOMEWORK_DIR}/32-app-splunk-test.yaml"

print_header "$MAGENTA" "DEPLOYING SPLUNK ARGO CD APPLICATIONS"

for f in "$APP_PROD" "$APP_DEV" "$APP_TEST"; do
  [[ -f "$f" ]] || log_error "Required file not found: $f"
done

print_header "$MAGENTA" "1. CHECK / INSTALL ARGO CD"
if kubectl get crd applications.argoproj.io >/dev/null 2>&1; then
  log_info "Argo CD Application CRD found."
else
  log_warn "Argo CD Application CRD not found. Installing Argo CD..."

  kubectl create namespace "${ARGOCD_NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -

  kubectl apply -n "${ARGOCD_NAMESPACE}" \
    --server-side \
    --force-conflicts \
    -f "${ARGOCD_INSTALL_URL}"

  log_info "Waiting for Argo CD deployments to become available..."
  kubectl -n "${ARGOCD_NAMESPACE}" wait --for=condition=Available deploy --all --timeout=300s
  kubectl -n "${ARGOCD_NAMESPACE}" rollout status statefulset/argocd-application-controller --timeout=300s
fi

print_header "$MAGENTA" "2. VERIFY ARGO CD CRDS"
kubectl get crd applications.argoproj.io >/dev/null 2>&1 || log_error "applications.argoproj.io CRD not found."
kubectl get crd appprojects.argoproj.io >/dev/null 2>&1 || log_error "appprojects.argoproj.io CRD not found."
kubectl get crd applicationsets.argoproj.io >/dev/null 2>&1 || log_error "applicationsets.argoproj.io CRD not found."

print_header "$MAGENTA" "3. VERIFY ARGO CD PODS"
kubectl -n "${ARGOCD_NAMESPACE}" get pods

print_header "$MAGENTA" "4. APPLY PROD APP"
kubectl apply -f "${APP_PROD}"

print_header "$MAGENTA" "5. APPLY DEV APP"
kubectl apply -f "${APP_DEV}"

print_header "$MAGENTA" "6. APPLY TEST APP"
kubectl apply -f "${APP_TEST}"

print_header "$TEAL" "7. VERIFY ARGO CD APPLICATIONS"
kubectl -n "${ARGOCD_NAMESPACE}" get applications || log_error "Unable to list Argo CD applications."

print_header "$MAGENTA" "APPLICATION DEPLOYMENT COMPLETE"
log_info "Splunk Applications submitted to Argo CD."