#!/usr/bin/env bash
# =============================================================================
# Script: 7-teardown.sh
# Purpose: Cleanly remove Project 3 lab resources in reverse order:
#          cheat tests, Argo CD apps, constraints, templates, namespaces,
#          Argo CD, Gatekeeper, artifacts, and Terraform infrastructure.
#
# Usage:   ./scripts/7-teardown.sh
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

safe_delete_file() {
  local path="$1"
  if [[ -f "${path}" ]]; then
    log_info "Deleting resource file: ${path}"
    kubectl delete -f "${path}" --ignore-not-found || true
  else
    log_warn "File not found, skipping: ${path}"
  fi
}

# -----------------------------------------------------------------------------
# CONFIG
# -----------------------------------------------------------------------------
TF_DIR="${TF_DIR:-.}"
PLAN_DESTROY="${PLAN_DESTROY:-false}"
HOMEWORK_DIR="${HOMEWORK_DIR:-homework}"
ARTIFACTS_DIR="${ARTIFACTS_DIR:-homework-results}"

GATEKEEPER_NAMESPACE="${GATEKEEPER_NAMESPACE:-gatekeeper-system}"
GATEKEEPER_RELEASE="${GATEKEEPER_RELEASE:-gatekeeper}"

ARGOCD_NAMESPACE="${ARGOCD_NAMESPACE:-argocd}"
REMOVE_ARTIFACTS="${REMOVE_ARTIFACTS:-false}"

CHEAT_NS_FILE="${HOMEWORK_DIR}/40-cheat-prod-to-dev.yaml"
CHEAT_PORT_FILE="${HOMEWORK_DIR}/41-cheat-prod-service-wrong-port.yaml"

APP_PROD="${HOMEWORK_DIR}/30-app-splunk-prod.yaml"
APP_DEV="${HOMEWORK_DIR}/31-app-splunk-dev.yaml"
APP_TEST="${HOMEWORK_DIR}/32-app-splunk-test.yaml"

ARGO_CONSTRAINT="${HOMEWORK_DIR}/11-constraint-argo-app-env-namespace.yaml"
PORT_CONSTRAINT="${HOMEWORK_DIR}/21-constraint-splunk-service-port-by-env.yaml"

ARGO_TEMPLATE="${HOMEWORK_DIR}/10-template-argo-app-env-namespace.yaml"
PORT_TEMPLATE="${HOMEWORK_DIR}/20-template-splunk-service-port-by-env.yaml"

NS_FILE="${HOMEWORK_DIR}/00-namespaces.yaml"

ARGOCD_INSTALL_URL="https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml"

print_header "$MAGENTA" "PROJECT 3 TEARDOWN"

command -v kubectl >/dev/null 2>&1 || log_error "kubectl not found."
command -v helm >/dev/null 2>&1 || log_error "helm not found."
command -v terraform >/dev/null 2>&1 || log_error "terraform not found."

print_header "$MAGENTA" "1. REMOVE CHEAT / NEGATIVE TEST RESOURCES"
safe_delete_file "${CHEAT_NS_FILE}"
safe_delete_file "${CHEAT_PORT_FILE}"

print_header "$MAGENTA" "2. REMOVE ARGO CD APPLICATIONS"
safe_delete_file "${APP_PROD}"
safe_delete_file "${APP_DEV}"
safe_delete_file "${APP_TEST}"

echo
echo "--- Argo CD application resources removal complete ---"
echo

print_header "$MAGENTA" "3. REMOVE GATEKEEPER CONSTRAINTS"
safe_delete_file "${PORT_CONSTRAINT}"
safe_delete_file "${ARGO_CONSTRAINT}"

print_header "$MAGENTA" "4. REMOVE GATEKEEPER CONSTRAINT TEMPLATES"
safe_delete_file "${PORT_TEMPLATE}"
safe_delete_file "${ARGO_TEMPLATE}"

echo
echo "--- Gatekeeper policy resources removal complete ---"
echo

print_header "$MAGENTA" "5. REMOVE SPLUNK NAMESPACES"
safe_delete_file "${NS_FILE}"

print_header "$MAGENTA" "6. REMOVE ARGO CD INSTALLATION"
if kubectl get namespace "${ARGOCD_NAMESPACE}" >/dev/null 2>&1; then
  log_info "Removing Argo CD install manifest resources"
  kubectl delete -n "${ARGOCD_NAMESPACE}" -f "${ARGOCD_INSTALL_URL}" --ignore-not-found || true
  kubectl delete namespace "${ARGOCD_NAMESPACE}" --ignore-not-found || true
else
  log_warn "Namespace ${ARGOCD_NAMESPACE} does not exist."
fi

print_header "$MAGENTA" "7. UNINSTALL GATEKEEPER"
if helm status "${GATEKEEPER_RELEASE}" -n "${GATEKEEPER_NAMESPACE}" >/dev/null 2>&1; then
  helm uninstall "${GATEKEEPER_RELEASE}" -n "${GATEKEEPER_NAMESPACE}" || true
else
  log_warn "Gatekeeper Helm release not found in namespace ${GATEKEEPER_NAMESPACE}"
fi

if kubectl get namespace "${GATEKEEPER_NAMESPACE}" >/dev/null 2>&1; then
  kubectl delete namespace "${GATEKEEPER_NAMESPACE}" --ignore-not-found || true
else
  log_warn "Namespace ${GATEKEEPER_NAMESPACE} does not exist."
fi

echo
echo "--- Argo CD and Gatekeeper removal complete ---"
echo

print_header "$MAGENTA" "8. OPTIONAL ARTIFACT CLEANUP"
if [[ "${REMOVE_ARTIFACTS}" == "true" ]]; then
  if [[ -d "${ARTIFACTS_DIR}" ]]; then
    rm -f "${ARTIFACTS_DIR}/outputs.txt" \
          "${ARTIFACTS_DIR}/resources.json" \
          "${ARTIFACTS_DIR}/json-commands.txt" 2>/dev/null || true
    log_info "Removed generated artifacts from ${ARTIFACTS_DIR}"
  else
    log_warn "Artifacts directory not found: ${ARTIFACTS_DIR}"
  fi
else
  log_info "Keeping generated artifacts in ${ARTIFACTS_DIR}"
fi

print_header "$MAGENTA" "9. DESTROY TERRAFORM INFRASTRUCTURE"
cd "${TF_DIR}"

if [[ "${PLAN_DESTROY}" == "true" ]]; then
  terraform plan -destroy -out destroy.tfplan
  terraform apply destroy.tfplan
else
  terraform destroy -auto-approve
fi

print_header "$TEAL" "TEARDOWN COMPLETE"
log_info "Project 3 resources have been removed."