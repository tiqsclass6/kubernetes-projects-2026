#!/usr/bin/env bash
# =============================================================================
# Script: 8-teardown.sh
# Purpose: Cleanly remove Flux GitOps objects, uninstall Flux controllers,
#          and destroy Terraform-managed infrastructure for Project 4 Flux.
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
FLUX_GITREPO_FILE="${LAB_GITHUB_DIR:-${PROJECT_ROOT}/flux/lab_github}/01-gitrepository.yaml"
FLUX_KUSTOMIZATION_FILE="${LAB_GITHUB_DIR:-${PROJECT_ROOT}/flux/lab_github}/02-kustomization-splunk-dev.yaml"

command -v kubectl >/dev/null 2>&1 || log_error "kubectl not found."
command -v terraform >/dev/null 2>&1 || log_error "terraform not found."

if [[ ! -d "${TERRAFORM_DIR}" ]]; then
  log_error "Terraform directory not found: ${TERRAFORM_DIR}"
fi

print_header "$MAGENTA" "1. REMOVE FLUX GITOPS OBJECTS"

if kubectl cluster-info >/dev/null 2>&1; then
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
  log_warn "Cluster is not reachable with kubectl. Skipping Flux object deletion."
fi

print_header "$MAGENTA" "2. REMOVE FLUX CONTROLLERS"

if kubectl cluster-info >/dev/null 2>&1; then
  kubectl delete -f https://github.com/fluxcd/flux2/releases/latest/download/install.yaml --ignore-not-found=true || true
  log_info "Flux controllers removal requested."
else
  log_warn "Cluster is not reachable with kubectl. Skipping Flux controller removal."
fi

print_header "$MAGENTA" "3. DESTROY TERRAFORM INFRASTRUCTURE"

cd "${TERRAFORM_DIR}"
terraform init -reconfigure
terraform destroy -auto-approve

print_header "$TEAL" "DESTROY COMPLETE"
log_info "Project 4 Flux infrastructure has been removed."