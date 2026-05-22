#!/usr/bin/env bash
# =============================================================================
# Script: teardown.sh
# Purpose: Clean up Kubernetes resources for Project 6 Kong/Chewbacca lab
# =============================================================================

set -Eeuo pipefail

# -----------------------------------------------------------------------------
# CONFIG
# -----------------------------------------------------------------------------
KONG_NAMESPACE="${KONG_NAMESPACE:-kong}"
CHEWBACCA_NAMESPACE="${CHEWBACCA_NAMESPACE:-chewbacca}"

# Defaults are safe for the current Project 6 layout:
# - App/Kong custom resources live in the chewbacca namespace.
# - Kong Helm release usually lives in the kong namespace.
DELETE_APP="${DELETE_APP:-true}"
DELETE_CHEWBACCA_NAMESPACE="${DELETE_CHEWBACCA_NAMESPACE:-false}"

# Set DELETE_KONG_HELM=true only when you intentionally want to remove the Kong
# Helm release before running terraform destroy.
DELETE_KONG_HELM="${DELETE_KONG_HELM:-false}"
DELETE_KONG_NAMESPACE="${DELETE_KONG_NAMESPACE:-false}"

WAIT_FOR_LB_DELETE="${WAIT_FOR_LB_DELETE:-true}"
HELM_RELEASE_NAME="${HELM_RELEASE_NAME:-kong}"

# Resource Names
KEY_INGRESS_NAME="hello-ingress"
RATE_LIMIT_INGRESS_NAME="hello-ratelimit-ingress"

KEY_AUTH_PLUGIN_NAME="key-auth-plugin"
RATE_LIMIT_PLUGIN_NAME="my-rate-limiting-plugin"

CONSUMER_NAME="chewbacca"
CONSUMER_SECRET_NAME="chewbacca-key"
HTML_CONFIGMAP_NAME="chewbacca-html"

APP_DEPLOYMENT_NAME="hello-app"
APP_SERVICE_NAME="hello-service"

# -----------------------------------------------------------------------------
# COLORS
# -----------------------------------------------------------------------------
MAGENTA='\033[0;95m'
TEAL='\033[0;36m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
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

print_step() {
  printf "\n---- %s\n" "$1"
}

log_info()  { printf "${GREEN}[INFO]${NC}  %s\n" "$*"; }
log_warn()  { printf "${YELLOW}[WARN]${NC}  %s\n" "$*"; }
log_error() { printf "${RED}[ERROR]${NC} %s\n" "$*" >&2; exit 1; }
log_pass()  { printf "${GREEN}[PASS]${NC}  %s\n" "$*"; }

# -----------------------------------------------------------------------------
# HELPERS
# -----------------------------------------------------------------------------
require_command() {
  command -v "${1}" >/dev/null 2>&1 || log_error "Required command not found: ${1}"
}

namespace_exists() {
  kubectl get namespace "$1" >/dev/null 2>&1
}

delete_if_exists() {
  local kind="$1"
  local name="$2"
  local namespace="${3:-}"

  if [[ -n "${namespace}" ]]; then
    if kubectl get "${kind}" "${name}" -n "${namespace}" >/dev/null 2>&1; then
      log_info "Deleting ${kind}/${name} in namespace ${namespace}"
      kubectl delete "${kind}" "${name}" -n "${namespace}" --ignore-not-found=true
    else
      log_warn "${kind}/${name} not found in namespace ${namespace}; skipping."
    fi
  else
    if kubectl get "${kind}" "${name}" >/dev/null 2>&1; then
      log_info "Deleting ${kind}/${name}"
      kubectl delete "${kind}" "${name}" --ignore-not-found=true
    else
      log_warn "${kind}/${name} not found; skipping."
    fi
  fi
}

helm_uninstall_if_exists() {
  local release="$1"
  local namespace="$2"

  require_command helm

  if helm status "${release}" -n "${namespace}" >/dev/null 2>&1; then
    log_info "Uninstalling Helm release ${release} from namespace ${namespace}"
    helm uninstall "${release}" -n "${namespace}"
  else
    log_warn "Helm release ${release} not found in namespace ${namespace}; skipping."
  fi
}

wait_for_loadbalancer_cleanup() {
  local namespace="$1"

  if [[ "${WAIT_FOR_LB_DELETE}" != "true" ]]; then
    log_warn "WAIT_FOR_LB_DELETE=false; skipping LoadBalancer cleanup wait."
    return 0
  fi

  if ! namespace_exists "${namespace}"; then
    log_pass "Namespace ${namespace} no longer exists; no LoadBalancer services remain there."
    return 0
  fi

  print_header "${MAGENTA}" "WAIT FOR KONG LOADBALANCER CLEANUP"

  for attempt in {1..30}; do
    local lbs
    lbs="$(kubectl get svc -n "${namespace}" \
      -o jsonpath='{range .items[?(@.spec.type=="LoadBalancer")]}{.metadata.name}{"\n"}{end}' 2>/dev/null || true)"

    if [[ -z "${lbs}" ]]; then
      log_pass "No LoadBalancer services remain in namespace ${namespace}."
      return 0
    fi

    log_warn "LoadBalancer still exists in ${namespace}: ${lbs//$'\n'/, }"
    sleep 10
  done

  log_warn "Timed out waiting for LoadBalancer cleanup. Check AWS console before destroying VPC resources."
}

print_resource_snapshot() {
  local namespace="$1"

  if namespace_exists "${namespace}"; then
    print_step "Remaining resources in namespace ${namespace}"
    kubectl get ingress,svc,deploy,configmap,secret,kongplugin,kongconsumer -n "${namespace}" 2>/dev/null || true
  else
    log_info "Namespace ${namespace} does not exist."
  fi
}

# -----------------------------------------------------------------------------
# MAIN
# -----------------------------------------------------------------------------
print_header "${TEAL}" "PROJECT 6 KONG KUBERNETES CLEAN TEARDOWN"

print_header "${MAGENTA}" "0. CHECK REQUIRED CLI TOOLS"
require_command kubectl

if [[ "${DELETE_KONG_HELM}" == "true" ]]; then
  require_command helm
fi

print_header "${MAGENTA}" "1. CHECK CLUSTER ACCESS"
kubectl cluster-info >/dev/null || log_error "Cannot reach Kubernetes cluster."

CURRENT_CONTEXT="$(kubectl config current-context)"
log_info "Current kubectl context: ${CURRENT_CONTEXT}"

print_header "${MAGENTA}" "2. DELETE CHEWBACCA INGRESS ROUTES"
delete_if_exists ingress "${KEY_INGRESS_NAME}" "${CHEWBACCA_NAMESPACE}"
delete_if_exists ingress "${RATE_LIMIT_INGRESS_NAME}" "${CHEWBACCA_NAMESPACE}"

print_header "${MAGENTA}" "3. DELETE KONG AUTH, PLUGIN, AND CONSUMER RESOURCES"
delete_if_exists kongplugin "${KEY_AUTH_PLUGIN_NAME}" "${CHEWBACCA_NAMESPACE}"
delete_if_exists kongplugin "${RATE_LIMIT_PLUGIN_NAME}" "${CHEWBACCA_NAMESPACE}"
delete_if_exists kongconsumer "${CONSUMER_NAME}" "${CHEWBACCA_NAMESPACE}"
delete_if_exists secret "${CONSUMER_SECRET_NAME}" "${CHEWBACCA_NAMESPACE}"

if [[ "${DELETE_APP}" == "true" ]]; then
  print_header "${MAGENTA}" "4. DELETE CHEWBACCA APPLICATION RESOURCES"
  delete_if_exists service "${APP_SERVICE_NAME}" "${CHEWBACCA_NAMESPACE}"
  delete_if_exists deployment "${APP_DEPLOYMENT_NAME}" "${CHEWBACCA_NAMESPACE}"
  delete_if_exists configmap "${HTML_CONFIGMAP_NAME}" "${CHEWBACCA_NAMESPACE}"
fi

if [[ "${DELETE_CHEWBACCA_NAMESPACE}" == "true" ]]; then
  print_header "${MAGENTA}" "5. DELETE CHEWBACCA NAMESPACE"
  delete_if_exists namespace "${CHEWBACCA_NAMESPACE}"
else
  log_warn "DELETE_CHEWBACCA_NAMESPACE=false; leaving namespace ${CHEWBACCA_NAMESPACE} in place."
fi

if [[ "${DELETE_KONG_HELM}" == "true" ]]; then
  print_header "${MAGENTA}" "6. DELETE KONG HELM RELEASE"
  helm_uninstall_if_exists "${HELM_RELEASE_NAME}" "${KONG_NAMESPACE}"
  wait_for_loadbalancer_cleanup "${KONG_NAMESPACE}"
else
  log_warn "DELETE_KONG_HELM=false; leaving Kong Helm release in place for terraform destroy."
fi

if [[ "${DELETE_KONG_NAMESPACE}" == "true" ]]; then
  print_header "${MAGENTA}" "7. DELETE KONG NAMESPACE"
  delete_if_exists namespace "${KONG_NAMESPACE}"
else
  log_warn "DELETE_KONG_NAMESPACE=false; leaving namespace ${KONG_NAMESPACE} in place."
fi

print_header "${MAGENTA}" "8. FINAL RESOURCE SNAPSHOT"
print_resource_snapshot "${CHEWBACCA_NAMESPACE}"

if namespace_exists "${KONG_NAMESPACE}"; then
  print_step "Kong LoadBalancer services in namespace ${KONG_NAMESPACE}"
  kubectl get svc -n "${KONG_NAMESPACE}" --field-selector metadata.namespace="${KONG_NAMESPACE}" 2>/dev/null || true
fi

print_header "${TEAL}" "KUBERNETES TEARDOWN COMPLETE"

log_info "Recommended next command when ready:"
printf "\n    terraform destroy\n\n"
log_info "To also remove Kong before Terraform destroy, run:"
printf "\n    DELETE_KONG_HELM=true ./scripts/teardown.sh\n\n"
