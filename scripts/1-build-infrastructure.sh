#!/usr/bin/env bash
# =============================================================================
# Script: 1-build-infrastructure.sh
# Purpose: Initialize, validate, plan, and apply the Terraform for the GKE
#          infrastructure used by Project 4 Flux.
#
# Usage:   ./scripts/1-build-infrastructure.sh
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

command -v terraform >/dev/null 2>&1 || log_error "terraform not found."

print_header "$MAGENTA" "1. INITIALIZE TERRAFORM"
cd "${TF_DIR}"
terraform init

print_header "$MAGENTA" "2. FORMAT AND VALIDATE"
terraform fmt -recursive
terraform validate

print_header "$MAGENTA" "3. PLAN INFRASTRUCTURE"
terraform plan -out=tfplan

print_header "$MAGENTA" "4. APPLY INFRASTRUCTURE"
terraform apply -auto-approve tfplan

print_header "$TEAL" "TERRAFORM APPLY COMPLETE"
log_info "GKE infrastructure is deployed."
log_info "Next step: ./scripts/2-gke-credentials.sh"