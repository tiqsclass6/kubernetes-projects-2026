#!/usr/bin/env bash
# =============================================================================
# Script: kong-teardown.sh
# Purpose:
#   Cleanly tear down the Kong Ingress Lab resources created by Terraform.
#
#   This script removes Kubernetes resources first, then Kong, then namespaces,
#   then runs a full Terraform destroy. This helps prevent AWS Internet Gateway
#   detach failures caused by lingering LoadBalancer resources.
#
# Usage:
#   chmod +x kong-teardown.sh
#   ./kong-teardown.sh
#
# Optional environment variables:
#   AWS_REGION=us-east-1
#   CHECK_AWS_LB=true
# =============================================================================

set -Eeuo pipefail

# -----------------------------------------------------------------------------
# COLORS
# -----------------------------------------------------------------------------
MAGENTA='\033[0;95m'
TEAL='\033[0;36m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# -----------------------------------------------------------------------------
# LOGGING
# -----------------------------------------------------------------------------
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

require_command() {
  local cmd="$1"
  command -v "${cmd}" >/dev/null 2>&1 || log_error "Required command not found: ${cmd}"
}

# -----------------------------------------------------------------------------
# CONFIG
# -----------------------------------------------------------------------------
AWS_REGION="${AWS_REGION:-us-east-1}"
TF_VARS_FILE="${TF_VARS_FILE:-}"
CHECK_AWS_LB="${CHECK_AWS_LB:-true}"

# Terraform resource names
TF_INGRESS_RESOURCE="${TF_INGRESS_RESOURCE:-kubernetes_ingress_v1.hello_ingress}"
TF_SERVICE_RESOURCE="${TF_SERVICE_RESOURCE:-kubernetes_service.hello_service}"
TF_DEPLOYMENT_RESOURCE="${TF_DEPLOYMENT_RESOURCE:-kubernetes_deployment.hello_app}"
TF_KONG_HELM_RESOURCE="${TF_KONG_HELM_RESOURCE:-helm_release.kong}"
TF_APP_NAMESPACE_RESOURCE="${TF_APP_NAMESPACE_RESOURCE:-kubernetes_namespace.app}"
TF_KONG_NAMESPACE_RESOURCE="${TF_KONG_NAMESPACE_RESOURCE:-kubernetes_namespace.kong}"

# Namespace names for verification only
APP_NAMESPACE="${APP_NAMESPACE:-apps}"
KONG_NAMESPACE="${KONG_NAMESPACE:-kong}"

# -----------------------------------------------------------------------------
# TERRAFORM HELPERS
# -----------------------------------------------------------------------------
tf_destroy_target() {
  local target="$1"

  if terraform state list | grep -qx "${target}"; then
    log_info "Destroying Terraform target: ${target}"

    if [[ -n "${TF_VARS_FILE}" && -f "${TF_VARS_FILE}" ]]; then
      terraform destroy -target="${target}" -auto-approve -var-file="${TF_VARS_FILE}"
    else
      terraform destroy -target="${target}" -auto-approve
    fi
  else
    log_warn "Terraform target not found in state, skipping: ${target}"
  fi
}

tf_full_destroy() {
  log_info "Running final full Terraform destroy"

  if [[ -n "${TF_VARS_FILE}" && -f "${TF_VARS_FILE}" ]]; then
    terraform destroy -auto-approve -var-file="${TF_VARS_FILE}"
  else
    terraform destroy -auto-approve
  fi
}

# -----------------------------------------------------------------------------
# AWS LOAD BALANCER CHECKS
# -----------------------------------------------------------------------------
check_classic_elb() {
  print_header "$MAGENTA" "CHECK CLASSIC LOAD BALANCERS"

  if ! command -v aws >/dev/null 2>&1; then
    log_warn "AWS CLI not found. Skipping Classic ELB check."
    return 0
  fi

  log_info "Checking Classic ELBs in region: ${AWS_REGION}"
  aws elb describe-load-balancers --region "${AWS_REGION}" || true
}

check_elbv2() {
  print_header "$MAGENTA" "CHECK ALB / NLB LOAD BALANCERS"

  if ! command -v aws >/dev/null 2>&1; then
    log_warn "AWS CLI not found. Skipping ELBv2 check."
    return 0
  fi

  log_info "Checking ALB/NLB resources in region: ${AWS_REGION}"
  aws elbv2 describe-load-balancers --region "${AWS_REGION}" || true
}

# -----------------------------------------------------------------------------
# MAIN
# -----------------------------------------------------------------------------
print_header "$TEAL" "KONG TERRAFORM CLEAN TEARDOWN"

require_command terraform

print_header "$MAGENTA" "0. SHOW TERRAFORM RESOURCES RELATED TO KONG / APP"
terraform state list | grep -E "kong|hello|namespace|ingress|service|deployment|helm" || \
  log_warn "No matching Kong/app Terraform resources found in state."

print_header "$MAGENTA" "1. DESTROY APPLICATION INGRESS"
tf_destroy_target "${TF_INGRESS_RESOURCE}"

print_header "$MAGENTA" "2. DESTROY APPLICATION SERVICE"
tf_destroy_target "${TF_SERVICE_RESOURCE}"

print_header "$MAGENTA" "3. DESTROY APPLICATION DEPLOYMENT"
tf_destroy_target "${TF_DEPLOYMENT_RESOURCE}"

print_header "$MAGENTA" "4. DESTROY KONG HELM RELEASE"
tf_destroy_target "${TF_KONG_HELM_RESOURCE}"

if [[ "${CHECK_AWS_LB}" == "true" ]]; then
  print_header "$MAGENTA" "5. CHECK FOR AWS LOAD BALANCERS CREATED BY KONG"
  log_warn "If a Kong-created LoadBalancer still exists, wait 2-5 minutes before final destroy."
  check_classic_elb
  check_elbv2
else
  log_info "Skipping AWS Load Balancer checks because CHECK_AWS_LB=false"
fi

print_header "$MAGENTA" "6. DESTROY APPLICATION NAMESPACE"
tf_destroy_target "${TF_APP_NAMESPACE_RESOURCE}"

print_header "$MAGENTA" "7. DESTROY KONG NAMESPACE"
tf_destroy_target "${TF_KONG_NAMESPACE_RESOURCE}"

print_header "$MAGENTA" "8. OPTIONAL KUBERNETES NAMESPACE VERIFICATION"
if command -v kubectl >/dev/null 2>&1; then
  kubectl get ns "${APP_NAMESPACE}" >/dev/null 2>&1 && \
    log_warn "Namespace still exists or terminating: ${APP_NAMESPACE}" || \
    log_info "Namespace not found: ${APP_NAMESPACE}"

  kubectl get ns "${KONG_NAMESPACE}" >/dev/null 2>&1 && \
    log_warn "Namespace still exists or terminating: ${KONG_NAMESPACE}" || \
    log_info "Namespace not found: ${KONG_NAMESPACE}"
else
  log_warn "kubectl not found. Skipping namespace verification."
fi

print_header "$MAGENTA" "9. FINAL FULL TERRAFORM DESTROY"
tf_full_destroy

print_header "$TEAL" "TEARDOWN COMPLETE"
log_info "Kong lab Terraform teardown finished."