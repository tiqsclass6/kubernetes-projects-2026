#!/usr/bin/env bash
# =============================================================================
# Script: 8-teardown.sh
# Purpose: Remove Flux controllers and destroy Terraform-managed infrastructure
#          for Project 4 Flux.
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

source "$(dirname "$0")/0-env.sh" >/dev/null

command -v kubectl >/dev/null 2>&1 || log_error "kubectl not found."
command -v terraform >/dev/null 2>&1 || log_error "terraform not found."

print_header "$MAGENTA" "1. REMOVE FLUX CONTROLLERS"
kubectl delete -f https://github.com/fluxcd/flux2/releases/latest/download/install.yaml || true

print_header "$MAGENTA" "2. DESTROY TERRAFORM INFRASTRUCTURE"
cd "${TF_DIR}"
terraform destroy -auto-approve

print_header "$MAGENTA" "DESTROY COMPLETE"
log_info "Project 4 Flux infrastructure has been removed."