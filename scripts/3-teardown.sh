#!/usr/bin/env bash
# ==============================================================================
# Project 7 - Kong Key Auth + Rate Limiting Teardown Script
# ==============================================================================

set -euo pipefail

KONG_NAMESPACE="${KONG_NAMESPACE:-kong}"
KONG_RELEASE="${KONG_RELEASE:-kong}"
RUN_TERRAFORM_DESTROY="${RUN_TERRAFORM_DESTROY:-false}"

# Optional GKE refresh settings.
GCP_PROJECT="${GCP_PROJECT:-class-6-5-tiqs}"
GKE_CLUSTER="${GKE_CLUSTER:-kong}"
GKE_ZONE="${GKE_ZONE:-us-central1-b}"

# Resolve paths from this script location:
# project-7/
# ├── manifests/
# ├── python/
# └── scripts/3-teardown.sh
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
MANIFEST_DIR="${MANIFEST_DIR:-${PROJECT_ROOT}/manifests}"

HELLO_CONFIGMAP_FILE="${HELLO_CONFIGMAP_FILE:-${MANIFEST_DIR}/hello-configmap.yaml}"
HELLO_DEPLOYMENT_FILE="${HELLO_DEPLOYMENT_FILE:-${MANIFEST_DIR}/hello-deployment.yaml}"
HELLO_SERVICE_FILE="${HELLO_SERVICE_FILE:-${MANIFEST_DIR}/hello-service.yaml}"
NGINX_CONFIG_FILE="${NGINX_CONFIG_FILE:-${MANIFEST_DIR}/nginx-config.yaml}"

KEY_AUTH_CREDENTIAL_FILE="${KEY_AUTH_CREDENTIAL_FILE:-${MANIFEST_DIR}/key-auth-credential.yaml}"
KONG_CONSUMER_FILE="${KONG_CONSUMER_FILE:-${MANIFEST_DIR}/kong-consumer.yaml}"
KEY_AUTH_PLUGIN_FILE="${KEY_AUTH_PLUGIN_FILE:-${MANIFEST_DIR}/key-auth-plugin.yaml}"
RATE_LIMIT_PLUGIN_FILE="${RATE_LIMIT_PLUGIN_FILE:-${MANIFEST_DIR}/rate-limit-plugin.yaml}"
RATE_LIMIT_INGRESS_FILE="${RATE_LIMIT_INGRESS_FILE:-${MANIFEST_DIR}/ingress-rate-limit-plugin.yaml}"

# Colors
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

print_step() {
  echo
  echo "---- $1"
}

fail() {
  echo
  echo "${RED}ERROR: $1${NC}" >&2
  exit 1
}

warn() {
  echo "${YELLOW}WARN: $1${NC}"
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || fail "'$1' is required but was not found in PATH."
}

confirm_action() {
  local prompt="$1"
  local response=""
  read -r -p "${prompt} (y/N): " response

  if [[ "${response}" != [yY] ]]; then
    echo "Aborted."
    exit 1
  fi
}

ask_yes_no() {
  local prompt="$1"
  local response=""
  read -r -p "${prompt} (y/N): " response
  [[ "${response}" == [yY] ]]
}

delete_if_exists() {
  local file="$1"

  if [[ -f "${file}" ]]; then
    kubectl delete -f "${file}" --ignore-not-found || true
  else
    echo "Skipping missing file: ${file}"
  fi
}

kubectl_reachable() {
  kubectl cluster-info >/dev/null 2>&1
}

refresh_gke_credentials() {
  if ! command -v gcloud >/dev/null 2>&1; then
    warn "gcloud was not found, so credentials cannot be refreshed automatically."
    echo "Manual command:"
    echo "gcloud container clusters get-credentials ${GKE_CLUSTER} --zone ${GKE_ZONE} --project ${GCP_PROJECT}"
    return 1
  fi

  print_step "Refreshing GKE credentials"
  gcloud container clusters get-credentials "${GKE_CLUSTER}" \
    --zone "${GKE_ZONE}" \
    --project "${GCP_PROJECT}"
}

print_header "${MAGENTA}" "PROJECT 7 KONG KEY AUTH + RATE LIMITING TEARDOWN"

print_step "Checking required CLI tools"
require_command kubectl
require_command helm

print_step "Checking resolved project paths"
echo "Project root : ${PROJECT_ROOT}"
echo "Manifest dir : ${MANIFEST_DIR}"

print_step "Checking Kubernetes cluster access"
KUBECTL_AVAILABLE="false"

if kubectl_reachable; then
  KUBECTL_AVAILABLE="true"
else
  warn "kubectl cannot currently reach the Kubernetes API server."
  echo
  echo "Current context, if available:"
  kubectl config current-context 2>/dev/null || true
  echo
  echo "Suggested refresh command:"
  echo "gcloud container clusters get-credentials ${GKE_CLUSTER} --zone ${GKE_ZONE} --project ${GCP_PROJECT}"
  echo

  if ask_yes_no "Try to refresh GKE credentials now?"; then
    refresh_gke_credentials || true

    if kubectl_reachable; then
      KUBECTL_AVAILABLE="true"
    else
      warn "kubectl is still unable to reach the cluster after credential refresh."
    fi
  fi
fi

if [[ "${KUBECTL_AVAILABLE}" == "true" ]]; then
  echo "Current kubectl context: $(kubectl config current-context)"
else
  warn "Kubernetes cleanup will be skipped because the cluster API is unreachable."
fi

print_header "${YELLOW}" "CONFIRM DESTRUCTIVE ACTION"
confirm_action "This will delete Project 7 Kubernetes resources when reachable, and optionally destroy Terraform. Continue?"

if [[ "${KUBECTL_AVAILABLE}" == "true" ]]; then
  print_header "${MAGENTA}" "DELETING KONG AUTHENTICATION AND RATE LIMITING RESOURCES"

  print_step "Deleting Ingress first"
  delete_if_exists "${RATE_LIMIT_INGRESS_FILE}"

  print_step "Deleting Kong plugins"
  delete_if_exists "${KEY_AUTH_PLUGIN_FILE}"
  delete_if_exists "${RATE_LIMIT_PLUGIN_FILE}"

  print_step "Deleting KongConsumer and key-auth credential"
  delete_if_exists "${KONG_CONSUMER_FILE}"
  delete_if_exists "${KEY_AUTH_CREDENTIAL_FILE}"

  print_header "${MAGENTA}" "DELETING APPLICATION RESOURCES"

  print_step "Deleting hello app resources"
  delete_if_exists "${HELLO_SERVICE_FILE}"
  delete_if_exists "${HELLO_DEPLOYMENT_FILE}"
  delete_if_exists "${HELLO_CONFIGMAP_FILE}"
  delete_if_exists "${NGINX_CONFIG_FILE}"

  print_step "Uninstalling Kong via Helm"
  helm uninstall "${KONG_RELEASE}" -n "${KONG_NAMESPACE}" 2>/dev/null || true

  print_step "Deleting Kong namespace"
  kubectl delete namespace "${KONG_NAMESPACE}" --force --grace-period=0 2>/dev/null || true

  print_header "${GREEN}" "KUBERNETES CLEANUP COMPLETE"
  echo "Kubernetes resources cleaned up."
else
  print_header "${YELLOW}" "KUBERNETES CLEANUP SKIPPED"
  echo "Skipped Kubernetes deletes because the API server was unreachable."
fi

print_header "${YELLOW}" "TERRAFORM DESTROY OPTION"

echo "To fully destroy infrastructure, run:"
echo "terraform destroy -auto-approve"

if [[ "${RUN_TERRAFORM_DESTROY}" == "true" ]]; then
  print_step "RUN_TERRAFORM_DESTROY=true detected"
  require_command terraform
  terraform destroy -auto-approve
else
  if ask_yes_no "Run terraform destroy now?"; then
    require_command terraform
    terraform destroy -auto-approve
  fi
fi

print_header "${GREEN}" "TEARDOWN COMPLETE"

echo "Project 7 teardown completed."
