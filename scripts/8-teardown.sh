#!/usr/bin/env bash
# =============================================================================
# Script: 8-teardown.sh
# Purpose: Cleanly remove Flux GitOps objects, optional ingress/cert-manager
#          add-ons, uninstall Flux controllers, and destroy Terraform-managed
#          infrastructure for Project 4 Flux.
#
# Notes:
#   - This script does NOT delete local proof artifacts such as:
#       * proof-of-project.md
#       * proof-resources.json
#       * python/collect-artifacts.py
#
# Usage:   ./scripts/8-teardown.sh
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

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

source "${SCRIPT_DIR}/0-env.sh" >/dev/null

TERRAFORM_DIR="${TF_DIR:-${PROJECT_ROOT}/terraform}"
FLUX_BASE_DIR="${LAB_GITHUB_DIR:-${PROJECT_ROOT}/flux/lab_github}"
TLS_BASE_DIR="${FLUX_BASE_DIR}/tls"
APP_BASE_DIR="${PROJECT_ROOT}/clusters/dev/splunk"

FLUX_GITREPO_FILE="${FLUX_BASE_DIR}/01-gitrepository.yaml"
FLUX_KUSTOMIZATION_FILE="${FLUX_BASE_DIR}/02-kustomization-splunk-dev.yaml"

APP_INGRESS_FILE="${APP_BASE_DIR}/ingress.yaml"
APP_ISSUER_FILE="${APP_BASE_DIR}/issuer.yaml"

PUBLIC_IP_INGRESS_FILE="${TLS_BASE_DIR}/public_ip_ingress.yaml"
PUBLIC_IP_ISSUER_FILE="${TLS_BASE_DIR}/public_ip_issuer.yaml"
PUBLIC_IP_TLS_ISSUER_FILE="${TLS_BASE_DIR}/public_ip_TLS_issuer.yaml"
TLS_KUSTOMIZATION_FILE="${TLS_BASE_DIR}/tls_kustomization.yaml"

command -v kubectl >/dev/null 2>&1 || log_error "kubectl not found."
command -v terraform >/dev/null 2>&1 || log_error "terraform not found."

if [[ ! -d "${TERRAFORM_DIR}" ]]; then
  log_error "Terraform directory not found: ${TERRAFORM_DIR}"
fi

cluster_reachable=false
if kubectl cluster-info >/dev/null 2>&1; then
  cluster_reachable=true
fi

print_header "$MAGENTA" "1. REMOVE APP-LEVEL FLUX OBJECTS"

if [[ "${cluster_reachable}" == true ]]; then
  # Remove optional TLS helper manifests first
  if [[ -f "${TLS_KUSTOMIZATION_FILE}" ]]; then
    kubectl delete -f "${TLS_KUSTOMIZATION_FILE}" --ignore-not-found=true || true
    log_info "Deleted TLS kustomization manifest."
  fi

  if [[ -f "${PUBLIC_IP_INGRESS_FILE}" ]]; then
    kubectl delete -f "${PUBLIC_IP_INGRESS_FILE}" --ignore-not-found=true || true
    log_info "Deleted public IP ingress manifest."
  fi

  if [[ -f "${PUBLIC_IP_ISSUER_FILE}" ]]; then
    kubectl delete -f "${PUBLIC_IP_ISSUER_FILE}" --ignore-not-found=true || true
    log_info "Deleted public IP issuer manifest."
  fi

  if [[ -f "${PUBLIC_IP_TLS_ISSUER_FILE}" ]]; then
    kubectl delete -f "${PUBLIC_IP_TLS_ISSUER_FILE}" --ignore-not-found=true || true
    log_info "Deleted public IP TLS issuer manifest."
  fi

  # Remove app manifests that now live under clusters/dev/splunk
  if [[ -f "${APP_INGRESS_FILE}" ]]; then
    kubectl delete -f "${APP_INGRESS_FILE}" --ignore-not-found=true || true
    log_info "Deleted app ingress manifest."
  else
    log_warn "App ingress file not found: ${APP_INGRESS_FILE}"
  fi

  if [[ -f "${APP_ISSUER_FILE}" ]]; then
    kubectl delete -f "${APP_ISSUER_FILE}" --ignore-not-found=true || true
    log_info "Deleted app issuer manifest."
  else
    log_warn "App issuer file not found: ${APP_ISSUER_FILE}"
  fi

  # Remove Flux control manifests
  if [[ -f "${FLUX_KUSTOMIZATION_FILE}" ]]; then
    kubectl delete -f "${FLUX_KUSTOMIZATION_FILE}" --ignore-not-found=true || true
    log_info "Deleted Flux Kustomization manifest."
  else
    log_warn "Flux Kustomization file not found: ${FLUX_KUSTOMIZATION_FILE}"
  fi

  if [[ -f "${FLUX_GITREPO_FILE}" ]]; then
    kubectl delete -f "${FLUX_GITREPO_FILE}" --ignore-not-found=true || true
    log_info "Deleted Flux GitRepository manifest."
  else
    log_warn "Flux GitRepository file not found: ${FLUX_GITREPO_FILE}"
  fi
else
  log_warn "Cluster is not reachable with kubectl. Skipping app-level object deletion."
fi

print_header "$MAGENTA" "2. REMOVE OPTIONAL CLUSTER ADD-ONS"

if [[ "${cluster_reachable}" == true ]]; then
  log_info "Removing ingress-nginx..."
  kubectl delete -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml --ignore-not-found=true || true

  log_info "Removing cert-manager..."
  kubectl delete -f https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.yaml --ignore-not-found=true || true

  # Best-effort cleanup for namespaces if resources are already mostly gone
  kubectl delete namespace ingress-nginx --ignore-not-found=true --timeout=60s || true
  kubectl delete namespace cert-manager --ignore-not-found=true --timeout=60s || true

  log_info "Optional add-on removal requested."
else
  log_warn "Cluster is not reachable with kubectl. Skipping ingress-nginx/cert-manager removal."
fi

print_header "$MAGENTA" "3. REMOVE FLUX CONTROLLERS"

if [[ "${cluster_reachable}" == true ]]; then
  kubectl delete -f https://github.com/fluxcd/flux2/releases/latest/download/install.yaml --ignore-not-found=true || true
  log_info "Flux controllers removal requested."
else
  log_warn "Cluster is not reachable with kubectl. Skipping Flux controller removal."
fi

print_header "$MAGENTA" "4. DESTROY TERRAFORM INFRASTRUCTURE"

cd "${TERRAFORM_DIR}"
terraform init -reconfigure
terraform destroy -auto-approve

print_header "$TEAL" "DESTROY COMPLETE"
log_info "Project 4 Flux infrastructure has been removed."
log_info "Local proof artifacts were preserved."