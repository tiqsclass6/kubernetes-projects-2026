#!/usr/bin/env bash
# =============================================================================
# Script: 1-build-infrastructure.sh
# Purpose: Initialize, validate, plan, and apply Terraform infrastructure for
#          the Project 3 EKS environment, then update kubeconfig.
#
# Usage:   ./scripts/1-build-infrastructure.sh
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

AWS_REGION="${AWS_REGION:-us-east-1}"
CLUSTER_NAME="${CLUSTER_NAME:-demo}"
TF_DIR="${TF_DIR:-.}"
PLAN_FILE="${PLAN_FILE:-tfplan}"

print_header "$MAGENTA" "BUILDING PROJECT 3 INFRASTRUCTURE"

command -v terraform >/dev/null 2>&1 || log_error "terraform not found."
command -v aws >/dev/null 2>&1 || log_error "aws not found."
command -v kubectl >/dev/null 2>&1 || log_error "kubectl not found."

cd "${TF_DIR}"

print_header "$MAGENTA" "1. TERRAFORM INIT"
terraform init

print_header "$MAGENTA" "2. TERRAFORM FORMAT"
terraform fmt -recursive

print_header "$MAGENTA" "3. TERRAFORM VALIDATE"
terraform validate

print_header "$MAGENTA" "4. TERRAFORM PLAN"
terraform plan -out "${PLAN_FILE}"

print_header "$MAGENTA" "5. TERRAFORM APPLY"
terraform apply "${PLAN_FILE}"

print_header "$MAGENTA" "6. UPDATE KUBECONFIG"
aws eks update-kubeconfig --region "${AWS_REGION}" --name "${CLUSTER_NAME}"

print_header "$TEAL" "7. CLUSTER VALIDATION"
kubectl cluster-info
echo
kubectl get nodes -o wide

print_header "$MAGENTA" "INFRASTRUCTURE BUILD COMPLETE"
log_info "Cluster '${CLUSTER_NAME}' is ready for the next phase."