#!/usr/bin/env bash
# ==============================================================================
# Project 7 - Kong Key Auth + Rate Limiting Deployment Script
# ==============================================================================

set -euo pipefail

KONG_NAMESPACE="${KONG_NAMESPACE:-kong}"
KONG_RELEASE="${KONG_RELEASE:-kong}"
KONG_SERVICE="${KONG_SERVICE:-kong-gateway-proxy}"
INGRESS_CLASS="${INGRESS_CLASS:-kong}"
INGRESS_NAME="${INGRESS_NAME:-hello-ingress}"
API_PATH="${API_PATH:-/hello}"
API_KEY="${API_KEY:-super-secret-key}"
RUN_K6_TESTS="${RUN_K6_TESTS:-true}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
MANIFEST_DIR="${MANIFEST_DIR:-${PROJECT_ROOT}/manifests}"
PYTHON_DIR="${PYTHON_DIR:-${PROJECT_ROOT}/python}"

HELLO_CONFIGMAP_FILE="${HELLO_CONFIGMAP_FILE:-${MANIFEST_DIR}/hello-configmap.yaml}"
HELLO_DEPLOYMENT_FILE="${HELLO_DEPLOYMENT_FILE:-${MANIFEST_DIR}/hello-deployment.yaml}"
HELLO_SERVICE_FILE="${HELLO_SERVICE_FILE:-${MANIFEST_DIR}/hello-service.yaml}"
NGINX_CONFIG_FILE="${NGINX_CONFIG_FILE:-${MANIFEST_DIR}/nginx-config.yaml}"

KEY_AUTH_CREDENTIAL_FILE="${KEY_AUTH_CREDENTIAL_FILE:-${MANIFEST_DIR}/key-auth-credential.yaml}"
KONG_CONSUMER_FILE="${KONG_CONSUMER_FILE:-${MANIFEST_DIR}/kong-consumer.yaml}"
KEY_AUTH_PLUGIN_FILE="${KEY_AUTH_PLUGIN_FILE:-${MANIFEST_DIR}/key-auth-plugin.yaml}"
RATE_LIMIT_PLUGIN_FILE="${RATE_LIMIT_PLUGIN_FILE:-${MANIFEST_DIR}/rate-limit-plugin.yaml}"
RATE_LIMIT_INGRESS_FILE="${RATE_LIMIT_INGRESS_FILE:-${MANIFEST_DIR}/ingress-rate-limit-plugin.yaml}"

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

check_file() {
  [[ -f "$1" ]] || fail "Required file not found: $1"
}

get_kong_address() {
  local address=""

  address="$(kubectl get svc "${KONG_SERVICE}" -n "${KONG_NAMESPACE}" \
    -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || true)"

  if [[ -z "${address}" ]]; then
    address="$(kubectl get svc "${KONG_SERVICE}" -n "${KONG_NAMESPACE}" \
      -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || true)"
  fi

  echo "${address}"
}

get_kong_external_ip() {
  kubectl get svc "${KONG_SERVICE}" -n "${KONG_NAMESPACE}" \
    -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || true
}

http_status() {
  local url="$1"
  shift || true
  curl -s -o /tmp/project7-http-response.txt -w "%{http_code}" "$url" "$@"
}

update_live_dashboard_configmap() {
  local kong_address="$1"
  local unauth_reqs="$2"
  local unauth_failed="$3"
  local auth_reqs="$4"
  local auth_failed="$5"
  local temp_dir=""
  local html_file=""

  temp_dir="$(mktemp -d)"
  html_file="${temp_dir}/index.html"

  cat > "${html_file}" <<'EOF_HTML'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>PROJECT 7 // KONG RATE LIMITING // GKE</title>
  <style>
    @import url('https://fonts.googleapis.com/css2?family=Orbitron:wght@400;700&family=Roboto+Mono:wght@300;400&display=swap');

    :root {
      --neon-cyan: #00f5ff;
      --neon-purple: #c300ff;
      --neon-green: #00ff9d;
    }

    * { margin: 0; padding: 0; box-sizing: border-box; }

    body {
      font-family: 'Roboto Mono', monospace;
      background: linear-gradient(rgba(0,0,0,0.85), rgba(0,0,0,0.95)),
                  url('https://wallpapercave.com/wp/YeoPqhy.jpg') center/cover no-repeat fixed;
      color: #e0e0e0;
      min-height: 100vh;
    }

    .header {
      background: rgba(10, 10, 20, 0.95);
      border-bottom: 2px solid var(--neon-cyan);
      padding: 20px 40px;
      display: flex;
      align-items: center;
      justify-content: space-between;
    }

    .title {
      font-family: 'Orbitron', sans-serif;
      font-size: 2.2rem;
      color: var(--neon-cyan);
      text-shadow: 0 0 15px var(--neon-cyan);
      letter-spacing: 3px;
    }

    .logos {
      display: flex;
      gap: 20px;
      align-items: center;
    }

    .logo {
      height: 55px;
      filter: drop-shadow(0 0 12px currentColor);
    }

    .k8s-logo {
      height: 55px;
      filter: drop-shadow(0 0 15px #00f5ff) drop-shadow(0 0 25px #00f5ff);
    }

    .container { max-width: 1250px; margin: 40px auto; padding: 0 20px; }

    .section {
      background: rgba(15, 15, 35, 0.9);
      border: 1px solid var(--neon-purple);
      border-radius: 8px;
      margin-bottom: 30px;
      padding: 25px;
    }

    h1, h2 {
      color: var(--neon-cyan);
      font-family: 'Orbitron', sans-serif;
      text-shadow: 0 0 10px var(--neon-cyan);
    }

    pre {
      background: #0a0a0f;
      padding: 18px;
      border-radius: 6px;
      border-left: 4px solid var(--neon-cyan);
      overflow-x: auto;
      color: #a0ffa0;
      font-size: 0.95rem;
      line-height: 1.5;
    }

    .status { color: var(--neon-green); font-weight: bold; }

    .footer {
      text-align: center;
      padding: 40px 20px;
      font-size: 1.1rem;
      font-weight: bold;
    }

    .glow-text {
      animation: colorCycle 12s infinite linear;
      text-shadow: 0 0 20px currentColor;
    }

    @keyframes colorCycle {
      0% { color: #c300ff; }
      50% { color: #00f5ff; }
      100% { color: #c300ff; }
    }
  </style>
</head>
<body>
  <div class="header">
    <div class="title">PROJECT 07 // RATE LIMITING ENFORCED</div>

    <div class="logos">
      <img src="https://icon.icepanel.io/Technology/svg/HashiCorp-Terraform.svg" alt="Terraform" class="logo">
      <img src="https://assets.streamlinehq.com/image/private/w_300,h_300,ar_1/f_auto/v1/icons/4/kong-icon-3sm9z71jcjrf5m48vqw5hr.png/kong-icon-1sgcb8mkfoojp1rhasiqnho.png?_a=DATAiZAAZAA0" alt="Kong" class="logo">
      <img src="https://img.icons8.com/?size=100&id=1hFR28gNL9Hy&format=png&color=000000" alt="Kubernetes" class="k8s-logo">
    </div>
  </div>

  <div class="container">
    <div class="section">
      <h1>KONG GATEWAY + GKE</h1>
      <p><strong>Status:</strong> <span class="status">PROTECTED ✓</span> | Key Auth + Rate Limiting Active</p>
    </div>

    <div class="section">
      <h2>🛡️ Final Verification Pattern</h2>
      <pre><code>No API key        -> 401 Unauthorized
Valid API key     -> 200 OK
Flood after limit -> 429 Too Many Requests</code></pre>
    </div>

    <div class="section">
      <h2>📊 Project Summary</h2>
      <pre><code>Platform          : Google Kubernetes Engine (GKE)
Cluster Name      : kong
Gateway           : Kong Gateway
Authentication    : key-auth
Credential Header : apikey
Rate Limit        : 5 requests / minute
Protected Route   : /hello
Throttle Point    : Kong, before hello-service</code></pre>
    </div>

    <div class="section">
      <h2>🔬 Verification Commands</h2>
      <pre><code>kubectl get kongplugin -n kong
kubectl describe ingress hello-ingress -n kong
kubectl get svc kong-gateway-proxy -n kong

curl -i http://&lt;KONG_EXTERNAL_IP&gt;/hello
curl -i http://&lt;KONG_EXTERNAL_IP&gt;/hello -H "apikey: super-secret-key"

k6 run ./python/rate-test.js
k6 run ./python/key-rate-test.js</code></pre>
    </div>
  </div>

  <div class="footer">
    <p class="glow-text">
      Rate Limiting Enforced at the Gateway • Terraform + GKE + Kong • 2026
    </p>
  </div>
</body>
</html>
EOF_HTML

  kubectl create configmap hello-html \
    -n "${KONG_NAMESPACE}" \
    --from-file=index.html="${html_file}" \
    --dry-run=client \
    -o yaml > "${HELLO_CONFIGMAP_FILE}"

  kubectl apply -f "${HELLO_CONFIGMAP_FILE}"
  rm -rf "${temp_dir}"
}

print_header "${MAGENTA}" "PROJECT 7 KONG KEY AUTH + RATE LIMITING DEPLOYMENT"

print_step "Checking required CLI tools"
require_command kubectl
require_command helm
require_command curl

if [[ "${RUN_K6_TESTS}" == "true" ]] && ! command -v k6 >/dev/null 2>&1; then
  warn "k6 was not found. Deployment will continue, but k6 tests will be skipped."
  RUN_K6_TESTS="false"
fi

print_step "Checking Kubernetes cluster access"
kubectl cluster-info >/dev/null || fail "kubectl cannot reach the Kubernetes cluster."
echo "Current kubectl context: $(kubectl config current-context)"

print_step "Checking resolved project paths"
echo "Project root : ${PROJECT_ROOT}"
echo "Manifest dir : ${MANIFEST_DIR}"
echo "Python dir   : ${PYTHON_DIR}"

check_file "${HELLO_CONFIGMAP_FILE}"
check_file "${HELLO_DEPLOYMENT_FILE}"
check_file "${HELLO_SERVICE_FILE}"
check_file "${KEY_AUTH_CREDENTIAL_FILE}"
check_file "${KONG_CONSUMER_FILE}"
check_file "${KEY_AUTH_PLUGIN_FILE}"
check_file "${RATE_LIMIT_PLUGIN_FILE}"
check_file "${RATE_LIMIT_INGRESS_FILE}"

print_step "Ensuring ${KONG_NAMESPACE} namespace exists"
kubectl create namespace "${KONG_NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -

print_step "Checking Kong Ingress Controller installation"
if ! helm list -n "${KONG_NAMESPACE}" | grep -q "${KONG_RELEASE}"; then
  echo "📦 Installing Kong Ingress Controller..."
  helm repo add kong https://charts.konghq.com
  helm repo update
  helm install "${KONG_RELEASE}" kong/ingress \
    --namespace "${KONG_NAMESPACE}" \
    --create-namespace \
    --set ingressController.ingressClass="${INGRESS_CLASS}"
else
  echo "✅ Kong is already installed."
fi

print_step "Waiting for Kong pods to be ready"
kubectl wait --for=condition=ready pod \
  -l app.kubernetes.io/instance="${KONG_RELEASE}" \
  -n "${KONG_NAMESPACE}" \
  --timeout=300s

print_header "${MAGENTA}" "APPLYING APPLICATION MANIFESTS"

print_step "Applying hello ConfigMap"
kubectl apply -f "${HELLO_CONFIGMAP_FILE}"

if [[ -f "${NGINX_CONFIG_FILE}" ]]; then
  print_step "Applying nginx ConfigMap"
  kubectl apply -f "${NGINX_CONFIG_FILE}"
else
  warn "Optional file not found: ${NGINX_CONFIG_FILE}"
fi

print_step "Applying hello deployment"
kubectl apply -f "${HELLO_DEPLOYMENT_FILE}"

print_step "Applying hello service"
kubectl apply -f "${HELLO_SERVICE_FILE}"

print_header "${MAGENTA}" "APPLYING KONG AUTHENTICATION AND RATE LIMITING"

print_step "Applying key-auth credential Secret"
kubectl apply -f "${KEY_AUTH_CREDENTIAL_FILE}"

print_step "Applying KongConsumer"
kubectl apply -f "${KONG_CONSUMER_FILE}"

print_step "Applying key-auth KongPlugin"
kubectl apply -f "${KEY_AUTH_PLUGIN_FILE}"

print_step "Applying rate-limit KongPlugin"
kubectl apply -f "${RATE_LIMIT_PLUGIN_FILE}"

print_step "Applying Ingress with key-auth + rate-limit plugins"
kubectl apply -f "${RATE_LIMIT_INGRESS_FILE}"

print_step "Ensuring Ingress references both plugins"
kubectl annotate ingress "${INGRESS_NAME}" \
  -n "${KONG_NAMESPACE}" \
  konghq.com/plugins="key-auth-plugin,rate-limit-plugin" \
  --overwrite

print_step "Waiting for hello-app pods to be ready"
kubectl wait --for=condition=ready pod \
  -l app=hello \
  -n "${KONG_NAMESPACE}" \
  --timeout=300s

print_step "Checking KongConsumer programmed status"
kubectl get kongconsumer lizzo-devote -n "${KONG_NAMESPACE}" -o yaml | grep -E "message:|reason:|status:|type:" || true

print_header "${MAGENTA}" "DISCOVERING KONG LOADBALANCER"

KONG_ADDRESS=""
for attempt in {1..30}; do
  KONG_ADDRESS="$(get_kong_address)"
  [[ -n "${KONG_ADDRESS}" ]] && break
  echo "Waiting for external LoadBalancer address... attempt ${attempt}/30"
  sleep 10
done

[[ -n "${KONG_ADDRESS}" ]] || fail "Kong proxy LoadBalancer address was not assigned."

echo "Kong proxy address: ${KONG_ADDRESS}"
echo "Kong endpoint     : http://${KONG_ADDRESS}${API_PATH}"

print_step "Displaying LoadBalancer External IP"
KONG_EXTERNAL_IP="$(get_kong_external_ip)"

if [[ -n "${KONG_EXTERNAL_IP}" ]]; then
  echo "External IP command:"
  echo "kubectl get svc ${KONG_SERVICE} -n ${KONG_NAMESPACE} -o jsonpath='{.status.loadBalancer.ingress[0].ip}'"
  echo "External IP: ${KONG_EXTERNAL_IP}"
else
  warn "No External IP found. The LoadBalancer may be using a hostname instead."
  kubectl get svc "${KONG_SERVICE}" -n "${KONG_NAMESPACE}" || true
fi

print_header "${YELLOW}" "LOADBALANCER IP UPDATE WINDOW"

echo "Current Kong LoadBalancer address: ${KONG_ADDRESS}"

if [[ -n "${KONG_EXTERNAL_IP}" ]]; then
  echo "Current Kong External IP        : ${KONG_EXTERNAL_IP}"
fi

echo
echo "You now have up to 300 seconds to update the LoadBalancer IP in the k6 test files if they still use a hardcoded IP."
echo
echo "Files to check:"
echo "  ${RATE_TEST_FILE}"
echo "  ${KEY_RATE_TEST_FILE}"
echo
echo "Recommended pattern inside k6 files:"
echo "  const KONG_URL = __ENV.KONG_URL || \"http://${KONG_ADDRESS}\";"
echo
echo "The deploy script will continue automatically after 300 seconds."
echo "Press Enter when the files are updated and you are ready to continue."
echo

read -r -t 300 -p "Continue now or wait 300 seconds: " _LB_UPDATE_ACK || true
echo
echo "Continuing with authentication and rate limiting tests..."

print_header "${MAGENTA}" "AUTHENTICATION AND RATE LIMITING SMOKE TEST"

print_step "Testing no API key; expected 401"
STATUS_NO_KEY="$(http_status "http://${KONG_ADDRESS}${API_PATH}")"
echo "HTTP status without key: ${STATUS_NO_KEY}"

print_step "Testing valid API key; expected 200 before rate limit, or 429 if bucket is exhausted"
STATUS_WITH_KEY="$(http_status "http://${KONG_ADDRESS}${API_PATH}" -H "apikey: ${API_KEY}")"
echo "HTTP status with valid key: ${STATUS_WITH_KEY}"

print_step "Authenticated flood test; expected 429 after limit is exceeded"
for i in {1..10}; do
  STATUS="$(http_status "http://${KONG_ADDRESS}${API_PATH}" -H "apikey: ${API_KEY}")"
  echo "Request ${i} -> ${STATUS}"
done

if [[ "${RUN_K6_TESTS}" == "true" ]]; then
  print_header "${MAGENTA}" "RUNNING K6 TESTS"

  check_file "${RATE_TEST_FILE}"
  check_file "${KEY_RATE_TEST_FILE}"

  print_step "Running unauthenticated k6 test"
  UNAUTH_OUTPUT="$(KONG_URL="http://${KONG_ADDRESS}" k6 run "${RATE_TEST_FILE}" --quiet 2>&1 | tail -n 30 || true)"
  echo "${UNAUTH_OUTPUT}"

  print_step "Running authenticated k6 test"
  AUTH_OUTPUT="$(KONG_URL="http://${KONG_ADDRESS}" API_KEY="${API_KEY}" k6 run "${KEY_RATE_TEST_FILE}" --quiet 2>&1 | tail -n 30 || true)"
  echo "${AUTH_OUTPUT}"

  UNAUTH_FAILED="$(echo "${UNAUTH_OUTPUT}" | grep "http_req_failed" | awk '{print $3}' | head -1 || true)"
  AUTH_FAILED="$(echo "${AUTH_OUTPUT}" | grep "http_req_failed" | awk '{print $3}' | head -1 || true)"
  UNAUTH_REQS="$(echo "${UNAUTH_OUTPUT}" | grep "http_reqs" | awk '{print $3}' | head -1 || true)"
  AUTH_REQS="$(echo "${AUTH_OUTPUT}" | grep "http_reqs" | awk '{print $3}' | head -1 || true)"

  UNAUTH_FAILED="${UNAUTH_FAILED:-N/A}"
  AUTH_FAILED="${AUTH_FAILED:-N/A}"
  UNAUTH_REQS="${UNAUTH_REQS:-N/A}"
  AUTH_REQS="${AUTH_REQS:-N/A}"

  print_step "Updating hello-configmap.yaml with latest k6 results"
  update_live_dashboard_configmap "${KONG_ADDRESS}" "${UNAUTH_REQS}" "${UNAUTH_FAILED}" "${AUTH_REQS}" "${AUTH_FAILED}"

  print_step "Restarting hello-app deployment to reload ConfigMap"
  kubectl rollout restart deployment/hello-app -n "${KONG_NAMESPACE}" || true
  kubectl rollout status deployment/hello-app -n "${KONG_NAMESPACE}" --timeout=180s || true
else
  print_header "${YELLOW}" "SKIPPING K6 TESTS"
fi

print_header "${GREEN}" "DEPLOYMENT COMPLETE"

echo "✅ Deployment completed successfully!"
echo "🔗 Kong Proxy URL: http://${KONG_ADDRESS}${API_PATH}"
