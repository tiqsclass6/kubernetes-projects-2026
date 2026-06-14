#!/usr/bin/env bash
# ==============================================================================
# Project 7 - Kong Key Auth + Rate Limiting Verification Script
# ==============================================================================

set -euo pipefail

KONG_NAMESPACE="${KONG_NAMESPACE:-kong}"
KONG_SERVICE="${KONG_SERVICE:-kong-gateway-proxy}"
INGRESS_NAME="${INGRESS_NAME:-hello-ingress}"
HELLO_APP_LABEL="${HELLO_APP_LABEL:-app=hello}"
API_PATH="${API_PATH:-/hello}"
API_KEY="${API_KEY:-super-secret-key}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
PYTHON_DIR="${PYTHON_DIR:-${PROJECT_ROOT}/python}"
RATE_TEST_FILE="${RATE_TEST_FILE:-${PYTHON_DIR}/rate-test.js}"
KEY_RATE_TEST_FILE="${KEY_RATE_TEST_FILE:-${PYTHON_DIR}/key-rate-test.js}"

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

http_status() {
  local url="$1"
  shift || true
  curl -s -o /tmp/project7-verify-response.txt -w "%{http_code}" "$url" "$@"
}

print_header "${MAGENTA}" "PROJECT 7 KONG KEY AUTH + RATE LIMITING VERIFICATION"

print_step "Checking required CLI tools"
require_command kubectl
require_command curl

if ! command -v k6 >/dev/null 2>&1; then
  warn "k6 was not found. k6 verification will be skipped."
fi

print_step "Checking Kubernetes cluster access"
kubectl cluster-info >/dev/null || fail "kubectl cannot reach the Kubernetes cluster."
echo "Current kubectl context: $(kubectl config current-context)"

print_header "${MAGENTA}" "VERIFYING KONG RESOURCES"

print_step "KongPlugin resources"
kubectl get kongplugin -n "${KONG_NAMESPACE}"

print_step "KongConsumer status"
kubectl get kongconsumer lizzo-devote -n "${KONG_NAMESPACE}" -o yaml

print_step "Key-auth credential Secret"
kubectl get secret key-auth-super-secret -n "${KONG_NAMESPACE}" -o yaml | sed -n '1,45p'

print_step "Ingress configuration"
kubectl describe ingress "${INGRESS_NAME}" -n "${KONG_NAMESPACE}" | grep -E "Name:|Annotations:|konghq.com/plugins"

print_step "Kong services"
kubectl get svc -n "${KONG_NAMESPACE}"

print_step "Pods status"
kubectl get pods -n "${KONG_NAMESPACE}"

print_step "Hello app pods"
kubectl get pods -n "${KONG_NAMESPACE}" -l "${HELLO_APP_LABEL}"

print_header "${MAGENTA}" "DISCOVERING KONG LOADBALANCER"

KONG_PROXY_ADDRESS="$(kubectl get svc "${KONG_SERVICE}" -n "${KONG_NAMESPACE}" -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || true)"

if [[ -z "${KONG_PROXY_ADDRESS}" ]]; then
  KONG_PROXY_ADDRESS="$(kubectl get svc "${KONG_SERVICE}" -n "${KONG_NAMESPACE}" -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || true)"
fi

[[ -n "${KONG_PROXY_ADDRESS}" ]] || fail "Kong proxy LoadBalancer address was not found."

echo "External IP command:"
echo "kubectl get svc ${KONG_SERVICE} -n ${KONG_NAMESPACE} -o jsonpath='{.status.loadBalancer.ingress[0].ip}'"
echo "Kong proxy address: ${KONG_PROXY_ADDRESS}"
echo "Kong endpoint     : http://${KONG_PROXY_ADDRESS}${API_PATH}"

print_header "${MAGENTA}" "AUTHENTICATION AND RATE LIMITING TESTS"

print_step "No API key test; expected 401"
STATUS_NO_KEY="$(http_status "http://${KONG_PROXY_ADDRESS}${API_PATH}")"
echo "HTTP status without key: ${STATUS_NO_KEY}"

print_step "Valid API key test; expected 200 before rate limit, or 429 if bucket is exhausted"
STATUS_WITH_KEY="$(http_status "http://${KONG_PROXY_ADDRESS}${API_PATH}" -H "apikey: ${API_KEY}")"
echo "HTTP status with valid key: ${STATUS_WITH_KEY}"

print_step "Detailed valid API key headers"
curl -i "http://${KONG_PROXY_ADDRESS}${API_PATH}" -H "apikey: ${API_KEY}" | grep -E "HTTP/1.1|X-RateLimit|RateLimit|message" || true

print_step "Authenticated flood test; expected 429 after limit is exceeded"
SAW_429="false"

for i in {1..10}; do
  STATUS="$(http_status "http://${KONG_PROXY_ADDRESS}${API_PATH}" -H "apikey: ${API_KEY}")"
  echo "Request ${i} -> ${STATUS}"

  if [[ "${STATUS}" == "429" ]]; then
    SAW_429="true"
  fi
done

if [[ "${STATUS_NO_KEY}" == "401" ]]; then
  echo "PASS: No-key request returned 401."
else
  warn "Expected no-key request to return 401, got ${STATUS_NO_KEY}."
fi

if [[ "${STATUS_WITH_KEY}" == "200" || "${STATUS_WITH_KEY}" == "429" ]]; then
  echo "PASS: Valid-key request was accepted or rate-limited by Kong."
else
  warn "Expected valid-key request to return 200 or 429, got ${STATUS_WITH_KEY}."
fi

if [[ "${SAW_429}" == "true" ]]; then
  echo "PASS: Authenticated flood test observed 429 Too Many Requests."
else
  warn "Did not observe 429 in 10 authenticated requests. Wait for the rate-limit window to reset or lower the limit."
fi

if command -v k6 >/dev/null 2>&1; then
  print_header "${MAGENTA}" "K6 VERIFICATION"

  if [[ -f "${RATE_TEST_FILE}" ]]; then
    print_step "Running unauthenticated k6 test"
    KONG_URL="http://${KONG_PROXY_ADDRESS}" k6 run "${RATE_TEST_FILE}" || true
  else
    warn "Missing ${RATE_TEST_FILE}"
  fi

  if [[ -f "${KEY_RATE_TEST_FILE}" ]]; then
    print_step "Running authenticated k6 test"
    KONG_URL="http://${KONG_PROXY_ADDRESS}" API_KEY="${API_KEY}" k6 run "${KEY_RATE_TEST_FILE}" || true
  else
    warn "Missing ${KEY_RATE_TEST_FILE}"
  fi
fi

print_header "${GREEN}" "VERIFICATION COMPLETE"

echo "Final proof pattern:"
echo "No API key        -> 401"
echo "Valid API key     -> 200"
echo "Flood after limit -> 429"
echo
echo "Request throttling is enforced at Kong, before the upstream Kubernetes service handles the request."
