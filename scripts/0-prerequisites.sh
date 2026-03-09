#!/usr/bin/env bash
# =============================================================================
# Script: 0-prerequisites.sh
# Purpose: Validate local tooling, AWS auth, kubectl context, and required files
#          for Project 3 (Gatekeeper + Argo CD Security for Splunk).
#
# Usage:   ./scripts/0-prerequisites.sh
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

AWS_REGION="${AWS_REGION:-us-east-1}"
CLUSTER_NAME="${CLUSTER_NAME:-demo}"
TF_DIR="${TF_DIR:-.}"
HOMEWORK_DIR="${HOMEWORK_DIR:-homework}"
ARGOCD_NAMESPACE="${ARGOCD_NAMESPACE:-argocd}"

REQUIRED_TF_FILES=(
  "0-var.tf"
  "1-auth.tf"
  "2-vpc.tf"
  "3-subnets.tf"
  "4-igw.tf"
  "5-nat.tf"
  "6-rtb.tf"
  "7-eks.tf"
  "8-node.tf"
  "9-runtime.tf"
  "10-iam-oidc.tf"
  "11a-storage-iam.tf"
  "11b-storage-helm.tf"
  "12-output.tf"
)

REQUIRED_HOMEWORK_FILES=(
  "00-namespaces.yaml"
  "10-template-argo-app-env-namespace.yaml"
  "11-constraint-argo-app-env-namespace.yaml"
  "20-template-splunk-service-port-by-env.yaml"
  "21-constraint-splunk-service-port-by-env.yaml"
  "30-app-splunk-prod.yaml"
  "31-app-splunk-dev.yaml"
  "32-app-splunk-test.yaml"
  "40-cheat-prod-to-dev.yaml"
  "41-cheat-prod-service-wrong-port.yaml"
)

check_command_exists() {
  local cmd="$1"
  command -v "$cmd" >/dev/null 2>&1 || log_error "Required command not found in PATH: $cmd"
}

check_file_exists() {
  local path="$1"
  [[ -f "$path" ]] || log_error "Required file not found: $path"
}

print_header "$MAGENTA" "PROJECT 3 PREFLIGHT CHECKS"

log_info "Validating required local tools..."
for cmd in bash aws kubectl helm terraform grep awk sed jq; do
  check_command_exists "$cmd"
done

log_info "Validating Terraform files..."
for f in "${REQUIRED_TF_FILES[@]}"; do
  check_file_exists "${TF_DIR}/${f}"
done

log_info "Validating homework files..."
for f in "${REQUIRED_HOMEWORK_FILES[@]}"; do
  check_file_exists "${HOMEWORK_DIR}/${f}"
done

log_info "Checking AWS caller identity..."
aws sts get-caller-identity >/dev/null 2>&1 || log_error "AWS authentication failed."

log_info "Checking current kubectl context..."
CURRENT_CONTEXT="$(kubectl config current-context 2>/dev/null || true)"
if [[ -z "${CURRENT_CONTEXT}" ]]; then
  log_warn "kubectl context is not set yet."
  log_info "Once infra is built, run:"
  echo "  aws eks update-kubeconfig --region ${AWS_REGION} --name ${CLUSTER_NAME}"
else
  log_info "kubectl current-context: ${CURRENT_CONTEXT}"
fi

log_info "Checking Helm access..."
helm version >/dev/null 2>&1 || log_error "Helm is not functioning correctly."

log_info "Checking whether Argo CD CRD already exists..."
if kubectl get crd applications.argoproj.io >/dev/null 2>&1; then
  log_info "Argo CD Application CRD found."
else
  log_warn "Argo CD Application CRD not found yet. Install Argo CD before running 4-deploy-apps.sh."
fi

print_header "$TEAL" "PREFLIGHT SUMMARY"
log_info "AWS Region         : ${AWS_REGION}"
log_info "Cluster Name       : ${CLUSTER_NAME}"
log_info "Terraform Dir      : ${TF_DIR}"
log_info "Homework Dir       : ${HOMEWORK_DIR}"
log_info "Argo CD Namespace  : ${ARGOCD_NAMESPACE}"
log_info "Preflight checks passed."