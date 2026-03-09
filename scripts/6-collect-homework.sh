#!/usr/bin/env bash
# =============================================================================
# Script: 6-collect-homework.sh
# Purpose: Run the exact homework proof commands and save the output to a file
#          that can be sent to Chewbacca. Also generates a JSON resource
#          inventory of the cluster.
#
# Usage:   ./scripts/6-collect-homework.sh
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

HOMEWORK_DIR="${HOMEWORK_DIR:-homework}"
ARGOCD_NAMESPACE="${ARGOCD_NAMESPACE:-argocd}"
GATEKEEPER_NAMESPACE="${GATEKEEPER_NAMESPACE:-gatekeeper-system}"
ARTIFACTS_DIR="${ARTIFACTS_DIR:-homework-results}"

OUTPUT_FILE="${ARTIFACTS_DIR}/outputs.txt"
JSON_FILE="${ARTIFACTS_DIR}/resources.json"

CHEAT_NS_FILE="${HOMEWORK_DIR}/40-cheat-prod-to-dev.yaml"
CHEAT_PORT_FILE="${HOMEWORK_DIR}/41-cheat-prod-service-wrong-port.yaml"

mkdir -p "${ARTIFACTS_DIR}"

run_and_capture() {
  local title="$1"
  local cmd="$2"

  {
    echo "======================================================================"
    echo "${title}"
    echo "======================================================================"
    echo "\$ ${cmd}"
    echo
    eval "${cmd}" 2>&1 || true
    echo
  } >> "${OUTPUT_FILE}"
}

print_header "$MAGENTA" "COLLECTING HOMEWORK EVIDENCE"

: > "${OUTPUT_FILE}"

{
  echo "Project 3 - Gatekeeper + Argo CD Security for Splunk"
  echo "Generated: $(date)"
  echo
} >> "${OUTPUT_FILE}"

run_and_capture "1. Gatekeeper Pods" \
"kubectl -n \"${GATEKEEPER_NAMESPACE}\" get pods"

run_and_capture "2. Gatekeeper Validating Webhooks" \
"kubectl get validatingwebhookconfigurations | grep gatekeeper"

run_and_capture "3. ConstraintTemplates" \
"kubectl get constrainttemplates | egrep 'k8sargoappenvironment|k8sserviceportbyenv'"

run_and_capture "4. Constraints" \
"kubectl get constraints | egrep 'argo-app-env-namespace-lock|splunk-service-port-lock'"

run_and_capture "5. Argo CD Applications" \
"kubectl -n \"${ARGOCD_NAMESPACE}\" get applications"

run_and_capture "6. Cheat Test - Prod to Dev Namespace" \
"kubectl apply -f \"${CHEAT_NS_FILE}\""

run_and_capture "7. Cheat Test - Prod Service Wrong Port" \
"kubectl apply -f \"${CHEAT_PORT_FILE}\""

print_header "$TEAL" "HOMEWORK OUTPUT WRITTEN"

log_info "Saved text evidence to: ${OUTPUT_FILE}"
log_info "Saved JSON inventory to: ${JSON_FILE}"

echo
cat "${OUTPUT_FILE}"

echo
echo "--- outputs.txt command results complete (Stage: TXT evidence collection) ---"
echo

print_header "$MAGENTA" "GENERATING JSON RESOURCE INVENTORY"

kubectl get nodes -o json > "${JSON_FILE}"

echo
echo "--- resources.json inventory commands executed (Stage: JSON resource collection) ---"
echo

print_header "$TEAL" "JSON RESOURCE INVENTORY PREVIEW"

cat "${JSON_FILE}" | jq .