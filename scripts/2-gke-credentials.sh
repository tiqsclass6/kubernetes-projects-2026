#!/usr/bin/env bash
# =============================================================================
# Script: 2-gke-credentials.sh
# Purpose: Authenticate to the target GCP project and fetch kubeconfig
#          credentials for the GKE cluster.
#
# Usage:   ./scripts/2-gke-credentials.sh
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

command -v gcloud >/dev/null 2>&1 || log_error "gcloud not found."
command -v kubectl >/dev/null 2>&1 || log_error "kubectl not found."
command -v gke-gcloud-auth-plugin >/dev/null 2>&1 || \
command -v gke-gcloud-auth-plugin.exe >/dev/null 2>&1 || \
  log_error "gke-gcloud-auth-plugin not found. Run: gcloud components install gke-gcloud-auth-plugin"

print_header "$MAGENTA" "1. SET ACTIVE GCP PROJECT"
gcloud config set project "${PROJECT_ID}"

print_header "$MAGENTA" "2. FETCH GKE CREDENTIALS"
gcloud container clusters get-credentials "${CLUSTER_NAME}" \
  --region "${REGION}" \
  --project "${PROJECT_ID}"

print_header "$TEAL" "3. VALIDATE CLUSTER ACCESS"
kubectl cluster-info
echo
kubectl get nodes -o wide

print_header "$MAGENTA" "GKE CREDENTIALS CONFIGURED"
log_info "kubectl is configured for cluster ${CLUSTER_NAME}."
log_info "Next step: ./scripts/3-install-flux.sh"