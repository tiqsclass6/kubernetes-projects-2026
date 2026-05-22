#!/usr/bin/env bash
# ==============================================================================
# Project 6 - Kong Ingress Deployment / Validation Script
# ==============================================================================

set -euo pipefail

KONG_NAMESPACE="${KONG_NAMESPACE:-kong}"
CHEWBACCA_NAMESPACE="${CHEWBACCA_NAMESPACE:-chewbacca}"

# Resolve paths from the script location so ./scripts/deploy.sh works from the repo root.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
MANIFEST_DIR="${MANIFEST_DIR:-${PROJECT_ROOT}/manifests}"
API_KEY="${API_KEY:-super-secret-key}"
SKIP_APPLY="${SKIP_APPLY:-false}"

# Manifest files
NAMESPACE_FILE="${MANIFEST_DIR}/chewbacca_ns.yaml"
KEY_AUTH_PLUGIN_FILE="${MANIFEST_DIR}/kong_plugin_api.yaml"
RATE_LIMIT_PLUGIN_FILE="${MANIFEST_DIR}/kong_plugin_ratelimit.yaml"
CONSUMER_FILE="${MANIFEST_DIR}/chewbacca.yaml"
KEY_INGRESS_FILE="${MANIFEST_DIR}/apply_key_ingress.yaml"
RATE_LIMIT_INGRESS_FILE="${MANIFEST_DIR}/apply_ratelimit_ingress.yaml"
CONFIGMAP_FILE="${MANIFEST_DIR}/chewbacca_configmap.yaml"
DEPLOYMENT_FILE="${MANIFEST_DIR}/chewbacca_deployment.yaml"
SERVICE_FILE="${MANIFEST_DIR}/chewbacca_service.yaml"
SECRET_FILE="${MANIFEST_DIR}/chewbacca_key.yaml"

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
  echo "ERROR: $1" >&2
  exit 1
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || fail "'$1' is required but was not found in PATH."
}

check_file() {
  [[ -f "$1" ]] || fail "Required manifest file not found: $1"
}

http_status() {
  local url="$1"
  shift || true
  curl -sS -o /tmp/kong-test-response.txt -w "%{http_code}" "$url" "$@"
}

print_header "${MAGENTA}" "PROJECT 6 KONG DEPLOYMENT VALIDATION"

print_step "Checking required CLI tools"
require_command kubectl
require_command curl

print_step "Checking Kubernetes cluster access"
kubectl cluster-info >/dev/null || fail "kubectl cannot reach the Kubernetes cluster."

CURRENT_CONTEXT="$(kubectl config current-context)"
echo "Current kubectl context: ${CURRENT_CONTEXT}"

print_step "Checking Kong namespace"
kubectl get namespace "${KONG_NAMESPACE}" >/dev/null 2>&1 || \
  fail "Namespace '${KONG_NAMESPACE}' was not found. Run terraform apply first so Kong is installed."

print_step "Ensuring chewbacca namespace exists"
kubectl get namespace "${CHEWBACCA_NAMESPACE}" >/dev/null 2>&1 || {
  check_file "${NAMESPACE_FILE}"
  kubectl apply -f "${NAMESPACE_FILE}"
}

print_step "Checking Kong CRDs"
kubectl get crd kongplugins.configuration.konghq.com >/dev/null 2>&1 || \
  fail "KongPlugin CRD was not found."

kubectl get crd kongconsumers.configuration.konghq.com >/dev/null 2>&1 || \
  fail "KongConsumer CRD was not found."

print_step "Checking manifest files"
check_file "${NAMESPACE_FILE}"
check_file "${KEY_AUTH_PLUGIN_FILE}"
check_file "${RATE_LIMIT_PLUGIN_FILE}"
check_file "${CONSUMER_FILE}"
check_file "${KEY_INGRESS_FILE}"
check_file "${RATE_LIMIT_INGRESS_FILE}"
check_file "${CONFIGMAP_FILE}"
check_file "${DEPLOYMENT_FILE}"
check_file "${SERVICE_FILE}"
check_file "${SECRET_FILE}"

if [[ "${SKIP_APPLY}" != "true" ]]; then
  print_header "${MAGENTA}" "APPLYING KONG MANIFESTS"

  print_step "Applying backend resources"
  kubectl apply -f "${CONFIGMAP_FILE}"
  kubectl apply -f "${DEPLOYMENT_FILE}"
  kubectl apply -f "${CONFIGMAP_FILE}"
  kubectl apply -f "${DEPLOYMENT_FILE}"
  kubectl apply -f "${SERVICE_FILE}"

  print_step "Applying KongPlugin resources"
  kubectl apply -f "${KEY_AUTH_PLUGIN_FILE}"
  kubectl apply -f "${RATE_LIMIT_PLUGIN_FILE}"

  print_step "Applying consumer API key Secret"
  kubectl apply -f "${SECRET_FILE}"

  print_step "Applying KongConsumer"
  kubectl apply -f "${CONSUMER_FILE}"

  print_step "Applying Ingress resources"
  kubectl apply -f "${KEY_INGRESS_FILE}"
  kubectl apply -f "${RATE_LIMIT_INGRESS_FILE}"
else
  print_header "${MAGENTA}" "SKIPPING MANIFEST APPLY"
  echo "SKIP_APPLY=true was set, so this script will only validate existing resources."
fi

print_header "${MAGENTA}" "DISCOVERING KONG LOADBALANCER"

print_step "Listing Kong services"
kubectl get svc -n "${KONG_NAMESPACE}"

print_step "Detecting Kong LoadBalancer service"
KONG_SERVICE="$(kubectl get svc -n "${KONG_NAMESPACE}" \
  -o jsonpath='{range .items[?(@.spec.type=="LoadBalancer")]}{.metadata.name}{"\n"}{end}' \
  | head -n 1)"

[[ -n "${KONG_SERVICE}" ]] || fail "No LoadBalancer service found in namespace '${KONG_NAMESPACE}'."

echo "Detected Kong LoadBalancer service: ${KONG_SERVICE}"

print_step "Waiting for Kong LoadBalancer hostname/address"
KONG_HOSTNAME=""

for attempt in {1..30}; do
  KONG_HOSTNAME="$(kubectl get svc -n "${KONG_NAMESPACE}" "${KONG_SERVICE}" \
    -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || true)"

  if [[ -z "${KONG_HOSTNAME}" ]]; then
    KONG_HOSTNAME="$(kubectl get svc -n "${KONG_NAMESPACE}" "${KONG_SERVICE}" \
      -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || true)"
  fi

  if [[ -n "${KONG_HOSTNAME}" ]]; then
    break
  fi

  echo "Waiting for external LoadBalancer address... attempt ${attempt}/30"
  sleep 10
done

[[ -n "${KONG_HOSTNAME}" ]] || fail "Kong LoadBalancer hostname/address was not assigned yet."

echo "KONG_HOSTNAME=${KONG_HOSTNAME}"

print_header "${MAGENTA}" "VERIFYING KONG RESOURCES"

print_step "KongPlugin resources"
kubectl get kongplugin -n "${CHEWBACCA_NAMESPACE}"

print_step "KongConsumer resources"
kubectl get kongconsumer -n "${CHEWBACCA_NAMESPACE}"

print_step "Chewbacca API key Secret"
kubectl get secret chewbacca-key -n "${CHEWBACCA_NAMESPACE}"

print_step "Ingress resources"
kubectl get ingress -n "${CHEWBACCA_NAMESPACE}"

print_step "Main protected Ingress details"
kubectl describe ingress hello-ingress -n "${CHEWBACCA_NAMESPACE}"

print_header "${MAGENTA}" "TESTING ROUTES"

print_step "Testing /hello without API key; expected HTTP 401"
STATUS_NO_KEY="$(http_status "http://${KONG_HOSTNAME}/hello")"
echo "HTTP status: ${STATUS_NO_KEY}"

if [[ "${STATUS_NO_KEY}" == "401" ]]; then
  echo "PASS: /hello correctly returned 401 without API key."
else
  echo "WARN: Expected 401 but received ${STATUS_NO_KEY}."
fi

print_step "Testing /hello with valid API key; expected HTTP 200"
STATUS_WITH_KEY="$(http_status "http://${KONG_HOSTNAME}/hello" -H "apikey: ${API_KEY}")"
echo "HTTP status: ${STATUS_WITH_KEY}"

if [[ "${STATUS_WITH_KEY}" == "200" ]]; then
  echo "PASS: /hello correctly returned 200 with valid API key."
else
  echo "WARN: Expected 200 but received ${STATUS_WITH_KEY}."
fi

print_step "Testing /hello-ratelimit route; expected initial HTTP 200"
STATUS_RATE_LIMIT="$(http_status "http://${KONG_HOSTNAME}/hello-ratelimit")"
echo "HTTP status: ${STATUS_RATE_LIMIT}"

if [[ "${STATUS_RATE_LIMIT}" == "200" ]]; then
  echo "PASS: /hello-ratelimit initially returned 200."
else
  echo "WARN: Expected 200 but received ${STATUS_RATE_LIMIT}."
fi

print_step "Testing rate limiting; expected HTTP 429 after repeated requests"
SAW_429="false"

for i in {1..10}; do
  STATUS="$(http_status "http://${KONG_HOSTNAME}/hello-ratelimit")"
  echo "Attempt ${i}: HTTP ${STATUS}"

  if [[ "${STATUS}" == "429" ]]; then
    SAW_429="true"
    break
  fi
done

if [[ "${SAW_429}" == "true" ]]; then
  echo "PASS: Rate limiting returned 429 Too Many Requests."
else
  echo "WARN: Did not observe 429 within 10 requests."
fi

print_header "${MAGENTA}" "DEPLOYMENT VALIDATION COMPLETE"

echo "Kong endpoint:"
echo "http://${KONG_HOSTNAME}"

echo
echo "Custom HTML Dashboard:"
echo "http://${KONG_HOSTNAME}/hello"
echo
echo "Useful manual test commands:"
echo "curl -i http://${KONG_HOSTNAME}/hello"
echo "curl -i http://${KONG_HOSTNAME}/hello -H \"apikey: ${API_KEY}\""
echo "curl -i http://${KONG_HOSTNAME}/hello-ratelimit"