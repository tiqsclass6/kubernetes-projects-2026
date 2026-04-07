#!/usr/bin/env bash
# =============================================================================
# Script: 7-reconcile-and-verify.sh
# Purpose: Reconcile Flux source + Kustomization after prerequisites are ready,
#          validate Splunk deployment state, and collect proof artifacts.
#
# Usage:   ./scripts/7-reconcile-and-verify.sh
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

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "${ROOT_DIR}/scripts/0-env.sh" >/dev/null

ARTIFACTS_DIR="${ROOT_DIR}/artifacts"
mkdir -p "${ARTIFACTS_DIR}"

print_header "$MAGENTA" "0. VALIDATE CLI DEPENDENCIES"

command -v kubectl >/dev/null 2>&1 || log_error "kubectl not found."
command -v flux >/dev/null 2>&1 || log_error "flux CLI not found."

PYTHON_CMD=()
if command -v python3 >/dev/null 2>&1; then
  PYTHON_CMD=(python3)
elif command -v python >/dev/null 2>&1; then
  PYTHON_CMD=(python)
elif command -v py >/dev/null 2>&1; then
  PYTHON_CMD=(py -3)
else
  log_error "Python not found. Install Python and ensure python3, python, or py is available in PATH."
fi

log_info "kubectl detected."
log_info "flux detected."
log_info "Python command selected: ${PYTHON_CMD[*]}"
log_info "Artifacts directory: ${ARTIFACTS_DIR}"

print_header "$MAGENTA" "1. VALIDATE PREREQUISITES BEFORE RECONCILE"

kubectl get crd clusterissuers.cert-manager.io >/dev/null 2>&1 || \
  log_error "clusterissuers.cert-manager.io CRD not found. Run 6-install-cert-manager.sh first."

kubectl get crd certificates.cert-manager.io >/dev/null 2>&1 || \
  log_error "certificates.cert-manager.io CRD not found. Run 6-install-cert-manager.sh first."

kubectl -n cert-manager get deploy cert-manager >/dev/null 2>&1 || \
  log_error "cert-manager deployment not found."

kubectl -n ingress-nginx get deploy ingress-nginx-controller >/dev/null 2>&1 || \
  log_error "ingress-nginx controller deployment not found."

log_info "cert-manager CRDs detected."
log_info "cert-manager deployment detected."
log_info "ingress-nginx deployment detected."

print_header "$TEAL" "2. SHOW PLATFORM READINESS STATE"

kubectl -n cert-manager get pods || true
echo
kubectl -n ingress-nginx get pods || true
echo
kubectl get crd | grep cert-manager || true

print_header "$MAGENTA" "3. RECONCILE FLUX GIT SOURCE"

if kubectl -n "${FLUX_NAMESPACE}" get gitrepository github-platform >/dev/null 2>&1; then
  flux reconcile source git github-platform -n "${FLUX_NAMESPACE}"
  log_info "Flux Git source reconcile completed."
else
  log_error "GitRepository github-platform not found in ${FLUX_NAMESPACE}."
fi

print_header "$MAGENTA" "4. RECONCILE SPLUNK KUSTOMIZATION"

if kubectl -n "${FLUX_NAMESPACE}" get kustomization splunk-dev >/dev/null 2>&1; then
  flux reconcile kustomization splunk-dev -n "${FLUX_NAMESPACE}" --with-source
  log_info "Flux Kustomization reconcile triggered."
else
  log_error "Kustomization splunk-dev not found in ${FLUX_NAMESPACE}."
fi

print_header "$TEAL" "5. WAIT FOR FLUX KUSTOMIZATION READY"

if kubectl wait kustomization/splunk-dev \
  -n "${FLUX_NAMESPACE}" \
  --for=condition=Ready=True \
  --timeout=10m; then
  log_info "Kustomization splunk-dev reached Ready=True."
else
  log_warn "Kustomization did not reach Ready=True within timeout. Continuing to collect diagnostics."
fi

echo
flux get kustomizations -A || true
echo
kubectl -n "${FLUX_NAMESPACE}" describe kustomization splunk-dev || true

print_header "$MAGENTA" "6. VALIDATE SPLUNK NAMESPACE AND WORKLOADS"

kubectl get ns | grep "${SPLUNK_NAMESPACE}" || true
echo
kubectl -n "${SPLUNK_NAMESPACE}" get pods,svc,pvc || true
echo
kubectl -n "${SPLUNK_NAMESPACE}" get statefulset || true
echo
kubectl -n "${SPLUNK_NAMESPACE}" describe pod splunk-0 || true

print_header "$TEAL" "7. VALIDATE INGRESS / TLS / ISSUER OBJECTS"

kubectl -n "${SPLUNK_NAMESPACE}" get ingress || true
echo
kubectl get clusterissuer || true
echo
kubectl -n "${SPLUNK_NAMESPACE}" get certificate || true
echo
kubectl -n "${SPLUNK_NAMESPACE}" get secret splunk-web-tls || true

print_header "$MAGENTA" "8. CHECK SPLUNK REACHABILITY SIGNALS"

if kubectl -n "${SPLUNK_NAMESPACE}" get svc splunk >/dev/null 2>&1; then
  kubectl -n "${SPLUNK_NAMESPACE}" get svc splunk
else
  log_warn "Splunk service not found."
fi

if command -v nc >/dev/null 2>&1; then
  if nc -z 127.0.0.1 8091 >/dev/null 2>&1; then
    log_info "localhost:8091 is reachable."
  else
    log_warn "localhost:8091 is not reachable. Use port-forward or ingress for UI access."
  fi
else
  log_warn "nc not found. Falling back to Python socket check."

  if "${PYTHON_CMD[@]}" -c "import socket,sys; s=socket.socket(); s.settimeout(2); s.connect(('127.0.0.1',8091)); s.close()" >/dev/null 2>&1; then
    log_info "localhost:8091 is reachable."
  else
    log_warn "localhost:8091 is not reachable. Use port-forward or ingress for UI access."
  fi
fi

print_header "$TEAL" "9. CAPTURE LOGS AND GENERATE PROOF ARTIFACTS"

TMP_SPLUNK_LOG="$(mktemp)"
TMP_FLUX_LOG="$(mktemp)"

if kubectl -n "${SPLUNK_NAMESPACE}" logs splunk-0 --tail=200 > "${TMP_SPLUNK_LOG}" 2>&1; then
  if [[ -s "${TMP_SPLUNK_LOG}" ]]; then
    mv "${TMP_SPLUNK_LOG}" "${ARTIFACTS_DIR}/splunk-logs.txt"
    log_info "Splunk logs captured."
  else
    rm -f "${TMP_SPLUNK_LOG}"
    log_warn "Splunk logs empty. Skipping file creation."
  fi
else
  rm -f "${TMP_SPLUNK_LOG}"
  log_warn "Failed to collect Splunk logs."
fi

if flux logs --level=error --kind=Kustomization --name=splunk-dev -n "${FLUX_NAMESPACE}" > "${TMP_FLUX_LOG}" 2>&1; then
  if [[ -s "${TMP_FLUX_LOG}" ]]; then
    mv "${TMP_FLUX_LOG}" "${ARTIFACTS_DIR}/flux-kustomization-errors.log"
    log_info "Flux error logs captured."
  else
    rm -f "${TMP_FLUX_LOG}"
    log_warn "Flux logs empty. Skipping file creation."
  fi
else
  rm -f "${TMP_FLUX_LOG}"
  log_warn "Failed to collect Flux logs."
fi

"${PYTHON_CMD[@]}" "${ROOT_DIR}/python/collect-artifacts.py"

log_info "Run-scoped artifacts generated under: ${ARTIFACTS_DIR}/runs"
log_info "Latest demo artifacts available under: ${ARTIFACTS_DIR}/latest"

print_header "$MAGENTA" "10. RECONCILE AND VERIFICATION COMPLETE"

log_info "Platform prerequisites validated."
log_info "Flux source reconciled."
log_info "Flux Kustomization reconciled."
log_info "Splunk deployment state checked."
log_info "Artifacts captured for demo and troubleshooting."
log_info "Next step: demonstrate Git change -> Flux reconcile -> cluster update."